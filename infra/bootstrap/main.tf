###############################################################################
# BOOTSTRAP - run ONCE from your laptop (local state).
# Creates:
#   * S3 bucket for the main stack's Terraform state (versioned, encrypted,
#     native S3 locking - no DynamoDB table needed)
#   * GitHub Actions OIDC provider + IAM role, so the pipeline deploys to AWS
#     without any long-lived access keys
###############################################################################

terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "terraform"
      Stack     = "bootstrap"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project" {
  type    = string
  default = "fruitbazar"
}

variable "github_repository" {
  description = "GitHub repo allowed to deploy, as owner/name (e.g. chandrakalyan2108/fruitbazar)"
  type        = string
}

variable "create_github_oidc_provider" {
  description = "Set false if this AWS account already has the token.actions.githubusercontent.com OIDC provider"
  type        = bool
  default     = true
}

data "aws_caller_identity" "current" {}

# ----------------------------------------------------------------------------
# Terraform state bucket
# ----------------------------------------------------------------------------
resource "aws_s3_bucket" "tf_state" {
  bucket = "${var.project}-tfstate-${data.aws_caller_identity.current.account_id}-${var.aws_region}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "tf_state_tls_only" {
  bucket = aws_s3_bucket.tf_state.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource  = [aws_s3_bucket.tf_state.arn, "${aws_s3_bucket.tf_state.arn}/*"]
      Condition = { Bool = { "aws:SecureTransport" = "false" } }
    }]
  })
  depends_on = [aws_s3_bucket_public_access_block.tf_state]
}

# ----------------------------------------------------------------------------
# GitHub Actions OIDC -> IAM role
# ----------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  count           = var.create_github_oidc_provider ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

locals {
  oidc_provider_arn = var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_deploy" {
  name                 = "${var.project}-github-deploy"
  max_session_duration = 7200

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # Only the main branch (deploys) and pull requests (plans) of THIS repo
          "token.actions.githubusercontent.com:sub" = [
            "repo:${var.github_repository}:ref:refs/heads/main",
            "repo:${var.github_repository}:pull_request",
            "repo:${var.github_repository}:environment:production",
          ]
        }
      }
    }]
  })
}

# PowerUserAccess covers VPC/ECS/ECR/RDS/ELB/ACM/Route53/Secrets/Logs/S3, but not IAM.
resource "aws_iam_role_policy_attachment" "power_user" {
  role       = aws_iam_role.github_deploy.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# IAM permissions scoped to roles/policies prefixed with the project name only.
resource "aws_iam_role_policy" "scoped_iam" {
  name = "${var.project}-scoped-iam"
  role = aws_iam_role.github_deploy.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ManageProjectRoles"
        Effect = "Allow"
        Action = ["iam:*"]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project}-*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.project}-*",
        ]
      },
      {
        Sid      = "ServiceLinkedRoles"
        Effect   = "Allow"
        Action   = ["iam:CreateServiceLinkedRole", "iam:GetRole"]
        Resource = "*"
      },
      {
        Sid      = "ReadOnlyIam"
        Effect   = "Allow"
        Action   = ["iam:List*", "iam:Get*"]
        Resource = "*"
      }
    ]
  })
}

output "tf_state_bucket" {
  value = aws_s3_bucket.tf_state.bucket
}

output "github_deploy_role_arn" {
  value = aws_iam_role.github_deploy.arn
}

output "next_steps" {
  value = <<-EOT
    Add these in GitHub -> Settings -> Secrets and variables -> Actions:
      Variables:  AWS_REGION=${var.aws_region}
                  TF_STATE_BUCKET=${aws_s3_bucket.tf_state.bucket}
                  AWS_DEPLOY_ROLE_ARN=${aws_iam_role.github_deploy.arn}
                  DOMAIN_NAME=<your Hostinger domain, e.g. fruitbazar.in>
                  DNS_MODE=route53   (or hostinger)
      Secrets:    HOSTINGER_API_TOKEN=<token from hPanel -> Account -> API>
  EOT
}
