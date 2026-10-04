terraform {
  # >= 1.10 for native S3 state locking (use_lockfile); >= 1.9 for cross-variable validation
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Partial config - bucket/key/region are passed with -backend-config
  # (see .github/workflows/deploy.yml and scripts/deploy.sh)
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
