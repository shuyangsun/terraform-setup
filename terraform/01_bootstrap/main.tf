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
  region = var.region
}

locals {
  env_mapping = {
    for env, name in var.environments : env => {
      is_prod             = env == "prod" || env == "production"
      bucket              = "${var.company_id}-tfstate-${env}-${var.region}"
      bucket_name         = "${var.company_name} Terraform State Bucket for ${name}"
      kms_key_name        = "${var.company_id}-tfstate-key-${env}-${var.region}"
      kms_key_description = "Used to encrypt Terraform state objects for bucket \"${var.company_id}-tfstate-${env}-${var.region}\"."
    }
  }
}

resource "aws_s3_bucket" "tf_state" {
  for_each = local.env_mapping
  bucket   = each.value.bucket

  tags = {
    Name = each.value.bucket_name
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  for_each = local.env_mapping
  bucket   = aws_s3_bucket.tf_state[each.key].id
  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_kms_key" "state_bucket" {
  for_each                = local.env_mapping
  description             = each.value.kms_key_description
  deletion_window_in_days = 10

  tags = {
    Name = each.value.kms_key_name
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  for_each = local.env_mapping
  bucket   = aws_s3_bucket.tf_state[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.state_bucket[each.key].arn
      sse_algorithm     = "aws:kms"
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_access_block" {
  for_each = local.env_mapping
  bucket   = aws_s3_bucket.tf_state[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle {
    prevent_destroy = false
  }
}
