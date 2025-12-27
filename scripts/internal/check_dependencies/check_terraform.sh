#!/bin/bash
# Check Terraform installation and version.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

MIN_TERRAFORM_VERSION="1.14.3"

echo "Checking Terraform installation..."
if ! command -v terraform &> /dev/null; then
    error "Terraform is not installed. Please install Terraform $MIN_TERRAFORM_VERSION or above."
    exit 1
fi

TERRAFORM_VERSION=$(terraform -version | head -n 1 | sed 's/Terraform v//')

if ! version_gte "$MIN_TERRAFORM_VERSION" "$TERRAFORM_VERSION"; then
    error "Terraform version $TERRAFORM_VERSION is below the required minimum version $MIN_TERRAFORM_VERSION"
    exit 1
fi
success "Terraform version $TERRAFORM_VERSION is installed."
