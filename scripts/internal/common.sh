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
