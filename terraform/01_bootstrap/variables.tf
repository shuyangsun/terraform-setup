variable "company_name" {
  description = "Name of the company in CamelCase (e.g., MyCompany)."
  type        = string

  validation {
    condition     = can(regex("^[A-Z]([a-zA-Z0-9])*$", var.company_name))
    error_message = "The project name MUST be in CamelCase (e.g., \"MyCompany\")."
  }
}

variable "company_id" {
  description = "Company ID in kebab-case (e.g., my-company)."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([a-z0-9]*(-[a-z0-9]+)*)?$", var.company_id))
    error_message = "The company ID MUST be in kebab-case (e.g., \"my-company\")."
  }
}

variable "region" {
  description = "Region to deploy the Terraform state S3 bucket."
  type        = string

  default = "us-east-1"
}

variable "environments" {
  description = "Environments to setup, the key is the environment in kebab-case, the value is the environment in CamelCase."
  type        = map(string)

  default = {
    "prod"    = "Prod",
    "staging" = "Staging",
    "shared-services" : "SharedServices"
  }

  validation {
    condition     = length(var.environments) >= 1
    error_message = "At least one environment must be specified."
  }
}
