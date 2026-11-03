# Lab: Orchestration Patterns (Glue → Step Functions → Durable Lambda)

**Topic:** Comparing three orchestration strategies for the same family-grouped data pipeline

## Pipeline overview
Input: `transactions.csv` — 50 household transactions across 5 families  
Processing: parse → shuffle by family_id → apply rules per partition  
Output: Parquet files partitioned by family, with spend aggregates and flags  

## Options being built
| | Option | Status |
|---|---|---|
| C | Glue 5 PySpark job | in progress |
| A | Step Functions + Lambda (Distributed Map) | todo |
| B | Durable Lambda (no Step Functions) | todo |

## Start a new session

```bash
git clone https://github.com/kunleoladiran/pluralsight-labs.git
cd pluralsight-labs/lab-orchestration
chmod +x setup.sh save-session.sh
./setup.sh
```

## Run the Glue job

```bash
aws glue start-job-run --job-name family-rules-processor
```

## Monitor the job

```bash
aws glue get-job-runs --job-name family-rules-processor \
  --query 'JobRuns[0].{State:JobRunState,Duration:ExecutionTime}'
```

## Check the output

```bash
BUCKET=$(terraform output -raw bucket_name)
aws s3 ls s3://$BUCKET/output/ --recursive
```

## End a session

```bash
./save-session.sh "describe what you did and what's next"
```

---
## Session notes
<!-- save-session.sh appends here automatically -->
