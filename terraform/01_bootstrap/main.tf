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

resource "aws_s3_bucket" "state_bucket" {
  for_each = local.env_mapping
  bucket   = each.value.bucket

  tags = {
    Name = each.value.bucket_name
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enable_versioning" {
  for_each = local.env_mapping
  bucket   = aws_s3_bucket.state_bucket[each.key].id
  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_key" "bucket_encryption_key" {
  for_each                = local.env_mapping
  description             = "Used to encrypt Terraform state objects for bucket \"${var.company_id}-tfstate-${each.key}-${var.region}\"."
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name = each.value.kms_key_name
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption_config" {
  for_each = local.env_mapping
  bucket   = aws_s3_bucket.state_bucket[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket_encryption_key[each.key].arn
      sse_algorithm     = each.value.is_prod ? "aws:kms:dsse" : "aws:kms"
    }
    bucket_key_enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_access_block" {
  for_each = local.env_mapping
  bucket   = aws_s3_bucket.state_bucket[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_policy" "state_bucket_readonly" {
  for_each    = local.env_mapping
  name        = each.value.readonly_policy_name
  path        = "/terraform/readonly/"
  description = "Read-only access to Terraform state in the \"${each.key}\" environment."

  policy = jsonencode({
    Version = local.iam_policy_version
    Statement = [
      {
        Sid    = "S3BucketReadOnly"
        Effect = "Allow"
        Action = local.readonly_actions
        Resource = [
          aws_s3_bucket.state_bucket[each.key].arn,
          "${aws_s3_bucket.state_bucket[each.key].arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "state_bucket_readwrite" {
  for_each    = local.env_mapping
  name        = each.value.rw_policy_name
  path        = "/terraform/readwrite/"
  description = "Read and write access to Terraform state in the \"${each.key}\" environment."

  policy = jsonencode({
    Version = local.iam_policy_version
    Statement = [
      {
        Sid    = "S3BucketReadWrite"
        Effect = "Allow"
        Action = local.readwrite_actions
        Resource = [
          aws_s3_bucket.state_bucket[each.key].arn,
          "${aws_s3_bucket.state_bucket[each.key].arn}/*"
        ]
      },
    ]
  })
}
