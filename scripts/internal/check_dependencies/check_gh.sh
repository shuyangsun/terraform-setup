#!/bin/bash
# Check GitHub CLI installation and version.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

MIN_GH_VERSION="2.83.2"

echo "Checking GitHub CLI installation..."
if ! command -v gh &> /dev/null; then
    error "GitHub CLI is not installed. Please install GitHub CLI $MIN_GH_VERSION or above."
    exit 1
fi

GH_VERSION=$(gh --version | head -n 1 | sed 's/gh version //' | awk '{print $1}')

if ! version_gte "$MIN_GH_VERSION" "$GH_VERSION"; then
    error "GitHub CLI version $GH_VERSION is below the required minimum version $MIN_GH_VERSION"
    exit 1
fi
success "GitHub CLI version $GH_VERSION is installed."
