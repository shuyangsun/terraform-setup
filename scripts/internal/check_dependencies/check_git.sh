#!/bin/bash
# Check Git installation and version.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

MIN_GIT_VERSION="2.52.0"

check_git_version() {
  GIT_VERSION=$(git --version | sed 's/git version //')
  if ! version_gte "$MIN_GIT_VERSION" "$GIT_VERSION"; then
    error "Git version $GIT_VERSION is below the required minimum version $MIN_GIT_VERSION"
    exit 1
  fi
  success "Git version $GIT_VERSION is installed."
}

echo "Checking Git installation..."
if command -v git &> /dev/null; then
  check_git_version
  exit 0
fi

error "Git is not installed."
echo "Would you like to install Git? Type 'yes' to confirm:"
read -r response

if [[ "$response" != "yes" ]]; then
  error "Git installation declined. Please install Git $MIN_GIT_VERSION or above manually."
  exit 1
fi

echo "Installing Git..."
if ! install_package "brew install git"; then
  error "Please install Git $MIN_GIT_VERSION or above manually."
  exit 1
fi

if command -v git &> /dev/null; then
  check_git_version
else
  error "Git installation failed."
  exit 1
fi
