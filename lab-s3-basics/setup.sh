#!/usr/bin/env bash
# Run this at the START of every new sandbox session.
# Usage: ./setup.sh
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 1. Verify AWS credentials ─────────────────────────────────────────────────
echo "==> Verifying AWS credentials..."
if ! aws sts get-caller-identity 2>/dev/null; then
  echo "ERROR: No valid AWS credentials found. Either:"
  echo "  1. You are in CloudShell (should work automatically — try again)"
  echo "  2. Export credentials manually:"
  echo "     export AWS_ACCESS_KEY_ID=..."
  echo "     export AWS_SECRET_ACCESS_KEY=..."
  echo "     export AWS_DEFAULT_REGION=us-east-1"
  exit 1
fi

# ── 2. Terraform init + apply ──────────────────────────────────────────────────
echo "==> Running Terraform..."
cd "$LAB_DIR"
terraform init -input=false
terraform apply -auto-approve -input=false

# ── 3. Upload seed files to S3 ────────────────────────────────────────────────
BUCKET=$(terraform output -raw bucket_name)
if [ -n "$(ls -A seed/ 2>/dev/null)" ]; then
  echo "==> Uploading seed files to s3://$BUCKET ..."
  aws s3 cp seed/ s3://$BUCKET/seed/ --recursive
fi

# ── 4. Print endpoints ────────────────────────────────────────────────────────
echo ""
echo "==> Lab is ready."
terraform output
