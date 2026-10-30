#!/bin/bash

# Tests for herdr-omarchy-theme. Needs bash, jq and coreutils, not Omarchy or
# Herdr: both are replaced by the doubles in tests/stubs.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/herdr-omarchy-theme"
FIXTURES="$ROOT/tests/fixtures"
export PATH="$ROOT/tests/stubs:$PATH"

failures=0
passed=0

setup() {
  WORK=$(mktemp -d)
  export HOME="$WORK/home"
  export HERDR_APP_HOME="$HOME/.config/herdr-app"
  export STUB_CALLS="$WORK/calls"
  unset STUB_LAYOUT
  mkdir -p "$HERDR_APP_HOME/layouts/.state"
  : >"$STUB_CALLS"
  use_palette dark
}

teardown() {
  rm -rf "$WORK"
}

use_palette() {
  cp "$FIXTURES/$1.tsv" "$WORK/colors.tsv"
  : >"$WORK/colors.toml"
  export OMARCHY_COLORS_TOML="$WORK/colors.toml"
}

theme_file() {
  echo "$HERDR_APP_HOME/themes/omarchy.json"
}

set_layout_theme() {
  echo "{\"theme\": $2}" >"$HERDR_APP_HOME/layouts/.state/$1.json"
}

assert_eq() {
  if [[ $1 != "$2" ]]; then
    echo "    expected: $2"
    echo "    actual:   $1"
    return 1
  fi
}

test_writes_the_palette_as_a_herdr_theme() {
  "$SCRIPT" || return 1
  jq -e . "$(theme_file)" >/dev/null || return 1
  assert_eq "$(jq -r .background "$(theme_file)")" "#151e26" &&
    assert_eq "$(jq -r .foreground "$(theme_file)")" "#ece5d8" &&
    assert_eq "$(jq -r .selection "$(theme_file)")" "#334d5d" &&
    assert_eq "$(jq -r .cursor "$(theme_file)")" "#fff7eb" &&
    assert_eq "$(jq -r .colors.accent "$(theme_file)")" "#f3b77b" &&
    assert_eq "$(jq -r '.ansi | length' "$(theme_file)")" "16" &&
    assert_eq "$(jq -r '.ansi[1]' "$(theme_file)")" "#ef8d80" &&
    assert_eq "$(jq -r '.ansi[15]' "$(theme_file)")" "#fff7eb"
}

test_without_a_window_only_writes_the_file() {
  set_layout_theme main '{"light": "paper", "dark": "omarchy"}'
  "$SCRIPT" || return 1
  [[ -f $(theme_file) ]] && assert_eq "$(cat "$STUB_CALLS")" ""
}

test_reloads_a_window_showing_omarchy() {
  export STUB_LAYOUT=main
  set_layout_theme main '{"light": "paper", "dark": "omarchy"}'
  "$SCRIPT" || return 1
  assert_eq "$(cat "$STUB_CALLS")" $'app.theme --name graphite\napp.theme --name omarchy'
}

test_reloads_through_paper_for_a_light_palette() {
  export STUB_LAYOUT=main
  set_layout_theme main '"omarchy"'
  use_palette light
  "$SCRIPT" || return 1
  assert_eq "$(cat "$STUB_CALLS")" $'app.theme --name paper\napp.theme --name omarchy'
}

test_leaves_a_window_on_another_theme_alone() {
  export STUB_LAYOUT=main
  set_layout_theme main '{"light": "paper", "dark": "graphite"}'
  "$SCRIPT" || return 1
  [[ -f $(theme_file) ]] && assert_eq "$(cat "$STUB_CALLS")" ""
}

test_does_nothing_when_the_palette_is_unchanged() {
  export STUB_LAYOUT=main
  set_layout_theme main '"omarchy"'
  "$SCRIPT" || return 1
  : >"$STUB_CALLS"
  "$SCRIPT" || return 1
  assert_eq "$(cat "$STUB_CALLS")" ""
}

test_uses_settings_theme_when_the_layout_has_none() {
  export STUB_LAYOUT=main
  echo '{"zoom": 1}' >"$HERDR_APP_HOME/layouts/.state/main.json"
  echo '{"theme": "omarchy"}' >"$HERDR_APP_HOME/settings.json"
  "$SCRIPT" || return 1
  assert_eq "$(cat "$STUB_CALLS")" $'app.theme --name graphite\napp.theme --name omarchy'
}

test_layout_theme_wins_over_settings() {
  export STUB_LAYOUT=main
  set_layout_theme main '"ink"'
  echo '{"theme": "omarchy"}' >"$HERDR_APP_HOME/settings.json"
  "$SCRIPT" || return 1
  assert_eq "$(cat "$STUB_CALLS")" ""
}

test_keeps_the_old_file_when_a_color_is_invalid() {
  "$SCRIPT" || return 1
  local before
  before=$(cat "$(theme_file)")
  sed -i 's/^background\t.*/background\tnot-a-color/' "$WORK/colors.tsv"
  "$SCRIPT" 2>/dev/null && return 1
  assert_eq "$(cat "$(theme_file)")" "$before" &&
    assert_eq "$(find "$HERDR_APP_HOME/themes" -type f | wc -l)" "1"
}

test_skips_when_herdr_is_not_installed() {
  rm -rf "$HERDR_APP_HOME"
  "$SCRIPT" || return 1
  [[ ! -e $HERDR_APP_HOME ]]
}

test_install_and_uninstall() {
  "$ROOT/install.sh" >/dev/null || return 1
  local hook="$HOME/.config/omarchy/hooks/theme-set.d/herdr-omarchy-theme"
  [[ -x $hook && -f $(theme_file) ]] || return 1
  "$ROOT/uninstall.sh" >/dev/null || return 1
  [[ ! -e $hook && ! -e $(theme_file) ]]
}

for test in $(declare -F | awk '$3 ~ /^test_/ { print $3 }'); do
  setup
  if output=$("$test" 2>&1); then
    echo "ok   ${test#test_}"
    passed=$((passed + 1))
  else
    echo "FAIL ${test#test_}"
    [[ -n $output ]] && echo "$output"
    failures=$((failures + 1))
  fi
  teardown
done

echo
echo "$passed passed, $failures failed"
(( failures == 0 ))
