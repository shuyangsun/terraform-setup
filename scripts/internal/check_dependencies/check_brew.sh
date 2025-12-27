#!/bin/bash
# Check Homebrew installation (macOS only).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

MIN_BREW_VERSION="5.0.7"

# Only run on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  exit 0
fi

check_brew_version() {
  BREW_VERSION=$(brew --version | head -n 1 | sed 's/Homebrew //')
  if ! version_gte "$MIN_BREW_VERSION" "$BREW_VERSION"; then
    error "Homebrew version $BREW_VERSION is below the required minimum version $MIN_BREW_VERSION"
    exit 1
  fi
  success "Homebrew version $BREW_VERSION is installed."
}

echo "Checking Homebrew installation..."
if command -v brew &> /dev/null; then
  check_brew_version
  brew update
  exit 0
fi

error "Homebrew is not installed."
echo "Would you like to install Homebrew? Type 'yes' to confirm:"
read -r response

if [[ "$response" != "yes" ]]; then
  error "Homebrew installation declined. Please install Homebrew manually following guide at https://brew.sh/."
  exit 1
fi

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if command -v brew &> /dev/null; then
  success "Homebrew installed successfully."
else
  error "Homebrew installation failed."
  exit 1
fi
