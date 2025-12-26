terraform {
  required_version = "~> 1.14.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27.0"
    }
  }
}

provider "aws" {
  region = var.regions[0]
}

locals {
  bucket_name = "${var.company_id}-tfstate-${keys(var.environments)[0]}-${var.regions[0]}"
  kms_name    = "${var.company_id}-tfstate-key-${keys(var.environments)[0]}-${var.regions[0]}"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = local.bucket_name

  tags = {
    Name = "${var.company_name} Bucket"
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "state_bucket" {
  description             = "Used to encrypt Terraform state objects in ${local.bucket_name}."
  deletion_window_in_days = 10

  tags = {
    Name = local.kms_name
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.state_bucket.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_access_block" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
