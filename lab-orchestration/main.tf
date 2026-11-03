terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {}

data "aws_caller_identity" "current" {}

locals {
  bucket_name = "orchestration-lab-${data.aws_caller_identity.current.account_id}"
}

# ── S3 Bucket ──────────────────────────────────────────────────────────────────
resource "aws_s3_bucket" "lab" {
  bucket = local.bucket_name
  tags   = { Lab = "orchestration" }
}

# ── IAM Role for Glue ─────────────────────────────────────────────────────────
resource "aws_iam_role" "glue" {
  name = "orchestration-lab-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3" {
  name = "glue-s3-access"
  role = aws_iam_role.glue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
      Resource = [
        aws_s3_bucket.lab.arn,
        "${aws_s3_bucket.lab.arn}/*"
      ]
    }]
  })
}

# ── Glue Catalog Database ─────────────────────────────────────────────────────
resource "aws_glue_catalog_database" "lab" {
  name = "orchestration_lab"
}

# ── Glue Job ──────────────────────────────────────────────────────────────────
resource "aws_glue_job" "family_processor" {
  name         = "family-rules-processor"
  role_arn     = aws_iam_role.glue.arn
  glue_version = "5.0"
  worker_type  = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://${local.bucket_name}/scripts/glue_job.py"
    python_version  = "3"
  }

  default_arguments = {
    "--JOB_NAME"   = "family-rules-processor"
    "--INPUT_PATH" = "s3://${local.bucket_name}/input/"
    "--OUTPUT_PATH"= "s3://${local.bucket_name}/output/"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-job-insights"              = "true"
  }
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "bucket_name" {
  value = aws_s3_bucket.lab.bucket
}

output "glue_job_name" {
  value = aws_glue_job.family_processor.name
}

output "glue_database" {
  value = aws_glue_catalog_database.lab.name
}

output "run_command" {
  value = "aws glue start-job-run --job-name ${aws_glue_job.family_processor.name}"
}
