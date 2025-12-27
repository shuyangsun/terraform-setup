#!/bin/bash
# Check Git installation and version.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

MIN_GIT_VERSION="2.52.0"

echo "Checking Git installation..."
if ! command -v git &> /dev/null; then
    error "Git is not installed. Please install Git $MIN_GIT_VERSION or above."
    exit 1
fi

GIT_VERSION=$(git --version | sed 's/git version //')

if ! version_gte "$MIN_GIT_VERSION" "$GIT_VERSION"; then
    error "Git version $GIT_VERSION is below the required minimum version $MIN_GIT_VERSION"
    exit 1
fi
success "Git version $GIT_VERSION is installed."
