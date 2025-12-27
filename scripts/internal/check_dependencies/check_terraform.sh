#!/bin/bash
# Check Terraform installation and version.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

MIN_TERRAFORM_VERSION="1.14.3"

check_terraform_version() {
  TERRAFORM_VERSION=$(terraform -version | head -n 1 | sed 's/Terraform v//')
  if ! version_gte "$MIN_TERRAFORM_VERSION" "$TERRAFORM_VERSION"; then
    warning "Terraform version $TERRAFORM_VERSION is below the required minimum version $MIN_TERRAFORM_VERSION"
    echo "Would you like to upgrade Terraform? Type 'yes' to confirm:"
    read -r response
    if [[ "$response" != "yes" ]]; then
      error "Terraform upgrade declined. Please upgrade Terraform to $MIN_TERRAFORM_VERSION or above manually."
      exit 1
    fi
    echo "Upgrading Terraform..."
    if ! install_package "brew upgrade hashicorp/tap/terraform"; then
      error "Failed to upgrade Terraform. Please upgrade Terraform to $MIN_TERRAFORM_VERSION or above manually."
      exit 1
    fi
    TERRAFORM_VERSION=$(terraform -version | head -n 1 | sed 's/Terraform v//')
    if ! version_gte "$MIN_TERRAFORM_VERSION" "$TERRAFORM_VERSION"; then
      error "Terraform version $TERRAFORM_VERSION is still below the required minimum version $MIN_TERRAFORM_VERSION after upgrade."
      exit 1
    fi
  fi
  success "Terraform version $TERRAFORM_VERSION is installed."
}

echo "Checking Terraform installation..."
if command -v terraform &> /dev/null; then
  check_terraform_version
  exit 0
fi

error "Terraform is not installed."
echo "Would you like to install Terraform? Type 'yes' to confirm:"
read -r response

if [[ "$response" != "yes" ]]; then
  error "Terraform installation declined. Please install Terraform $MIN_TERRAFORM_VERSION or above manually."
  exit 1
fi

echo "Installing Terraform..."
if ! install_package "brew tap hashicorp/tap" "brew install hashicorp/tap/terraform"; then
  error "Please install Terraform $MIN_TERRAFORM_VERSION or above manually."
  exit 1
fi

if command -v terraform &> /dev/null; then
  check_terraform_version
else
  error "Terraform installation failed."
  exit 1
fi
