#!/bin/bash
# Check GitHub CLI installation and version.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

MIN_GH_VERSION="2.83.2"

check_gh_version() {
  GH_VERSION=$(gh --version | head -n 1 | sed 's/gh version //' | awk '{print $1}')
  if ! version_gte "$MIN_GH_VERSION" "$GH_VERSION"; then
    warning "GitHub CLI version $GH_VERSION is below the required minimum version $MIN_GH_VERSION"
    echo "Would you like to upgrade GitHub CLI? Type 'yes' to confirm:"
    read -r response
    if [[ "$response" != "yes" ]]; then
      error "GitHub CLI upgrade declined. Please upgrade GitHub CLI to $MIN_GH_VERSION or above manually."
      exit 1
    fi
    echo "Upgrading GitHub CLI..."
    if ! install_package "brew upgrade gh"; then
      error "Failed to upgrade GitHub CLI. Please upgrade GitHub CLI to $MIN_GH_VERSION or above manually."
      exit 1
    fi
    GH_VERSION=$(gh --version | head -n 1 | sed 's/gh version //' | awk '{print $1}')
    if ! version_gte "$MIN_GH_VERSION" "$GH_VERSION"; then
      error "GitHub CLI version $GH_VERSION is still below the required minimum version $MIN_GH_VERSION after upgrade."
      exit 1
    fi
  fi
  success "GitHub CLI version $GH_VERSION is installed."
}

echo "Checking GitHub CLI installation..."
if command -v gh &> /dev/null; then
  check_gh_version
  exit 0
fi

error "GitHub CLI is not installed."
echo "Would you like to install GitHub CLI? Type 'yes' to confirm:"
read -r response

if [[ "$response" != "yes" ]]; then
  error "GitHub CLI installation declined. Please install GitHub CLI $MIN_GH_VERSION or above manually."
  exit 1
fi

echo "Installing GitHub CLI..."
if ! install_package "brew install gh"; then
  error "Please install GitHub CLI $MIN_GH_VERSION or above manually."
  exit 1
fi

if command -v gh &> /dev/null; then
  check_gh_version
else
  error "GitHub CLI installation failed."
  exit 1
fi
