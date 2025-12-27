#!/bin/bash
# Check AWS CLI installation, version, and configuration.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

MIN_AWS_VERSION="2.32.22"

echo "Checking AWS CLI installation..."
if ! command -v aws &> /dev/null; then
    error "AWS CLI is not installed. Please install AWS CLI $MIN_AWS_VERSION or above."
    exit 1
fi

AWS_VERSION=$(aws --version | awk '{print $1}' | cut -d'/' -f2)

if ! version_gte "$MIN_AWS_VERSION" "$AWS_VERSION"; then
    error "AWS CLI version $AWS_VERSION is below the required minimum version $MIN_AWS_VERSION"
    exit 1
fi
success "AWS CLI version $AWS_VERSION is installed."

echo "Checking AWS CLI configuration..."
if ! aws sts get-caller-identity &> /dev/null; then
    error "AWS CLI is not configured or credentials are invalid."
    echo "  Please run 'aws configure' to set up your credentials."
    exit 1
fi

CALLER_IDENTITY=$(aws sts get-caller-identity --output text --query 'Arn')
success "AWS CLI is configured. Current caller: $CALLER_IDENTITY"
