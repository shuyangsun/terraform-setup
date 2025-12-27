#!/bin/bash
# Common definitions for setup scripts.

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Symbols
CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"

# Helper functions
success() {
  echo -e "${CHECK} $1"
}

error() {
  echo -e "${CROSS} $1"
}

# Check if actual version is greater than or equal to required version.
# Uses semantic versioning comparison.
# Arguments:
#   $1 - required version (e.g., "2.0.0")
#   $2 - actual version (e.g., "2.1.0")
# Returns:
#   0 if actual >= required, 1 otherwise
version_gte() {
  local required="$1"
  local actual="$2"
  [ "$(printf '%s\n' "$required" "$actual" | sort -V | head -n1)" = "$required" ]
}

# Install a package using the system package manager.
# Arguments:
#   $@ - commands to run for installation
# Returns:
#   0 if installation succeeds, 1 otherwise
install_package() {
  if [[ "$(uname)" == "Darwin" ]]; then
    if ! command -v brew &> /dev/null; then
      error "Homebrew is not installed. Please install Homebrew first."
      return 1
    fi
    for cmd in "$@"; do
      eval "$cmd" || return 1
    done
  # TODO: Add Linux support (apt, yum, etc.)
  # TODO: Add Windows support (winget, choco, etc.)
  else
    error "Automatic installation is not supported on this platform."
    return 1
  fi
}
