import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import functions as F
from pyspark.sql.window import Window

args = getResolvedOptions(sys.argv, ["JOB_NAME", "INPUT_PATH", "OUTPUT_PATH"])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# ── 1. Parse ───────────────────────────────────────────────────────────────────
df = spark.read.option("header", "true").option("inferSchema", "true").csv(args["INPUT_PATH"])

# ── 2. Shuffle rows by family (repartition so each partition = one family) ────
df = df.repartition("family_id")

# ── 3. Rules per partition ────────────────────────────────────────────────────
window = Window.partitionBy("family_id")

df = (
    df
    # Total spend per family
    .withColumn("family_total_spend", F.sum("amount").over(window))
    # Transaction count per family
    .withColumn("family_tx_count", F.count("transaction_id").over(window))
    # Average transaction amount per family
    .withColumn("family_avg_amount", F.round(F.avg("amount").over(window), 2))
    # Flag families whose total spend exceeds $2000
    .withColumn("family_over_threshold", F.col("family_total_spend") > 2000)
    # Count flagged transactions per family
    .withColumn(
        "family_flagged_count",
        F.sum(F.when(F.col("status") == "flagged", 1).otherwise(0)).over(window),
    )
)

# ── 4. Write output partitioned by family ─────────────────────────────────────
df.write.mode("overwrite").partitionBy("family_id").parquet(args["OUTPUT_PATH"])

print(f"Done. Processed {df.count()} rows across {df.select('family_id').distinct().count()} families.")

job.commit()
