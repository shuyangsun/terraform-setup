locals {
  env_mapping = {
    for env, name in var.environments : env => {
      is_prod = env == "prod" || env == "production"

      # Terraform State S3 Buckets
      bucket       = "${var.company_id}-tfstate-${env}-${var.region}"
      bucket_name  = "${var.company_name} Terraform State Bucket for ${name}"
      kms_key_name = "${var.company_id}-tfstate-key-${env}-${var.region}"

      # IAM Policies
      readonly_policy_name = "TerraformState${name}ReadOnly"
      rw_policy_name       = "TerraformState${name}ReadWrite"
    }
  }

  iam_policy_version = "2012-10-17"
  readonly_actions   = ["s3:ListBucket", "s3:GetObject"]
  readwrite_actions = concat(
    local.readonly_actions,
    ["s3:PutObject", "s3:DeleteObject"]
  )
}
