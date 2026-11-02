#!/usr/bin/env bash
# Run this at the START of every new sandbox session.
# Usage: ./setup.sh
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 1. Configure AWS CLI ───────────────────────────────────────────────────────
echo "==> Configuring AWS CLI..."
if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
  echo "ERROR: Export AWS credentials first:"
  echo "  export AWS_ACCESS_KEY_ID=..."
  echo "  export AWS_SECRET_ACCESS_KEY=..."
  echo "  export AWS_DEFAULT_REGION=us-east-1"
  exit 1
fi
aws sts get-caller-identity

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
