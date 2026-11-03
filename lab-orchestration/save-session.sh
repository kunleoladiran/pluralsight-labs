#!/usr/bin/env bash
# Run this BEFORE the session expires (set a 3h15m alarm).
# Usage: ./save-session.sh "note on where you stopped"
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
NOTE="${1:-WIP}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

# ── 1. Export Terraform state ─────────────────────────────────────────────────
echo "==> Saving Terraform state..."
cd "$LAB_DIR"
terraform show -json > terraform-state-export.json 2>/dev/null || true

# ── 2. Sync S3 output back to seed/ ──────────────────────────────────────────
if command -v terraform &>/dev/null && terraform output bucket_name &>/dev/null 2>&1; then
  BUCKET=$(terraform output -raw bucket_name)
  echo "==> Syncing s3://$BUCKET/input/ back to seed/..."
  aws s3 sync "s3://$BUCKET/input/" "$LAB_DIR/seed/" --exclude "*.gitkeep"
fi

# ── 3. Update README with session note ───────────────────────────────────────
echo "==> Updating README..."
cat >> "$LAB_DIR/README.md" <<EOF

---
## Session note — $TIMESTAMP
$NOTE
EOF

# ── 4. Commit and push ────────────────────────────────────────────────────────
echo "==> Committing..."
cd "$LAB_DIR"
git add -A
git commit -m "session checkpoint: $NOTE [$TIMESTAMP]"
git push

echo ""
echo "==> Saved. Safe to let the session expire."
