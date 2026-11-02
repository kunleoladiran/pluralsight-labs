terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Reads AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION from env
}

# ── Variables ──────────────────────────────────────────────────────────────────
variable "lab_name" {
  description = "Short name for this lab (used in resource names)"
  default     = "my-lab"
}

# ── Resources ─────────────────────────────────────────────────────────────────
# Add your AWS resources here. Example:
# resource "aws_s3_bucket" "main" {
#   bucket = "${var.lab_name}-${data.aws_caller_identity.current.account_id}"
# }

data "aws_caller_identity" "current" {}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
