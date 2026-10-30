#!/bin/bash

# Remove the Omarchy theme for the Herdr desktop app.

set -euo pipefail

HOOK_PATH="$HOME/.config/omarchy/hooks/theme-set.d/herdr-omarchy-theme"
HERDR_APP_HOME="${HERDR_APP_HOME:-$HOME/.config/herdr-app}"
THEME_FILE="$HERDR_APP_HOME/themes/omarchy.json"

rm -f "$HOOK_PATH"
echo "Removed $HOOK_PATH"

# Herdr keeps showing a theme it already loaded, so move the window back to
# its default dark and light presets before the file goes away.
if grep -qs '"omarchy"' "$HERDR_APP_HOME"/layouts/.state/*.json "$HERDR_APP_HOME/settings.json" &&
  command -v herdr-app >/dev/null 2>&1 && timeout 5 herdr-app status >/dev/null 2>&1; then
  timeout 5 herdr-app do app.theme --name graphite >/dev/null 2>&1 || true
  timeout 5 herdr-app do app.theme --name paper >/dev/null 2>&1 || true
  echo "Switched Herdr back to its default themes (graphite / paper)."
fi

rm -f "$THEME_FILE"
echo "Removed $THEME_FILE"
