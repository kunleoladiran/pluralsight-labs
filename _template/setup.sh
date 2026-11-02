#!/usr/bin/env bash
# Run this at the START of every new sandbox session.
# Usage: ./setup.sh
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 1. Verify AWS credentials ─────────────────────────────────────────────────
echo "==> Verifying AWS credentials..."
# Works with explicit env vars (sandbox terminal) or CloudShell's implicit auth
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

# ── 3. Load seed data ──────────────────────────────────────────────────────────
echo "==> Loading seed data..."
# Uncomment and adapt as needed:
# aws s3 cp seed/ s3://$(terraform output -raw bucket_name)/ --recursive
# psql "$DB_URL" < seed/schema.sql

# ── 4. Print endpoints ────────────────────────────────────────────────────────
echo ""
echo "==> Lab is ready. Outputs:"
terraform output
