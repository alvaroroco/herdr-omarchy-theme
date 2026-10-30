#!/bin/bash

# Install the Omarchy theme for the Herdr desktop app.

set -euo pipefail

HOOK_NAME="herdr-omarchy-theme"
SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$HOOK_NAME"
HOOK_DIR="$HOME/.config/omarchy/hooks/theme-set.d"
HERDR_APP_HOME="${HERDR_APP_HOME:-$HOME/.config/herdr-app}"

fail() {
  echo "error: $*" >&2
  exit 1
}

command -v omarchy-theme-color >/dev/null 2>&1 ||
  fail "omarchy-theme-color not found. This needs Omarchy 4 or newer."
command -v jq >/dev/null 2>&1 ||
  fail "jq not found. Install it with: omarchy pkg add jq"
[[ -d $HERDR_APP_HOME ]] ||
  fail "$HERDR_APP_HOME not found. Install the Herdr desktop app and open it once."
[[ -f $SOURCE ]] ||
  fail "$SOURCE not found. Run install.sh from a clone of the repository."

mkdir -p "$HOOK_DIR"
install -m 755 "$SOURCE" "$HOOK_DIR/$HOOK_NAME"
echo "Installed theme-set hook: $HOOK_DIR/$HOOK_NAME"

"$HOOK_DIR/$HOOK_NAME"
echo "Wrote $HERDR_APP_HOME/themes/omarchy.json from your current Omarchy theme."
echo
echo "Pick it in Herdr: Settings -> Look -> omarchy"
echo "or run: herdr-app do app.theme --name omarchy"
