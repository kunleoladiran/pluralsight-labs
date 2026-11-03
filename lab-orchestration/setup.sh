#!/usr/bin/env bash
# Run this at the START of every new sandbox session.
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 1. Verify AWS credentials ─────────────────────────────────────────────────
echo "==> Verifying AWS credentials..."
if ! aws sts get-caller-identity 2>/dev/null; then
  echo "ERROR: No valid AWS credentials. Export them or use CloudShell."
  exit 1
fi

# ── 2. Install Terraform if missing ──────────────────────────────────────────
if ! command -v terraform &>/dev/null; then
  echo "==> Installing Terraform..."
  sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
  sudo yum -y install terraform
fi

# ── 3. Terraform init + apply ─────────────────────────────────────────────────
echo "==> Running Terraform..."
cd "$LAB_DIR"
terraform init -input=false
terraform apply -auto-approve -input=false

# ── 4. Upload script and seed data to S3 ─────────────────────────────────────
BUCKET=$(terraform output -raw bucket_name)

echo "==> Uploading Glue script to s3://$BUCKET/scripts/ ..."
aws s3 cp "$LAB_DIR/glue_job.py" "s3://$BUCKET/scripts/glue_job.py"

if [ -n "$(ls -A "$LAB_DIR/seed/" 2>/dev/null)" ]; then
  echo "==> Uploading seed data to s3://$BUCKET/input/ ..."
  aws s3 cp "$LAB_DIR/seed/" "s3://$BUCKET/input/" --recursive --exclude ".gitkeep"
fi

# ── 5. Print next steps ───────────────────────────────────────────────────────
echo ""
echo "==> Lab is ready."
terraform output
echo ""
echo "To run the Glue job:"
echo "  $(terraform output -raw run_command)"
echo ""
echo "To monitor the job:"
echo "  aws glue get-job-runs --job-name $(terraform output -raw glue_job_name) --query 'JobRuns[0].{State:JobRunState,Duration:ExecutionTime}'"
