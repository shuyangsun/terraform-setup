#!/bin/bash
# Setup new startup cloud infrastructure.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEP_ERR_EXIT=1

# ==============================================================================
# 1. Check Dependencies
# ==============================================================================

"$SCRIPT_DIR/internal/check_dependencies/check_git.sh" || exit ${DEP_ERR_EXIT}
"$SCRIPT_DIR/internal/check_dependencies/check_terraform.sh" || exit ${DEP_ERR_EXIT}
"$SCRIPT_DIR/internal/check_dependencies/check_aws.sh" || exit ${DEP_ERR_EXIT}
