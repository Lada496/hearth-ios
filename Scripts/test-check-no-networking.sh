#!/usr/bin/env bash

set -euo pipefail

fixture_root="$(mktemp -d)"
trap 'rm -rf "$fixture_root"' EXIT

safe_source="$fixture_root/Safe"
forbidden_source="$fixture_root/Forbidden"
safe_project="$fixture_root/project.pbxproj"
mkdir -p "$safe_source" "$forbidden_source"

printf 'import Foundation\nstruct OfflineValue {}\n' > "$safe_source/Safe.swift"
printf '// No linked frameworks\n' > "$safe_project"

Scripts/check-no-networking.sh "$safe_source" "$safe_project" >/dev/null

assert_rejected() {
  local source_text="$1"
  printf '%s\n' "$source_text" > "$forbidden_source/Forbidden.swift"

  if Scripts/check-no-networking.sh "$forbidden_source" - >/dev/null 2>&1; then
    echo "Networking guardrail self-test failed to reject: $source_text" >&2
    exit 1
  fi
}

assert_rejected 'let session: URLSession?'
assert_rejected 'let connection: NWConnection?'
assert_rejected 'import Network'

printf 'Network.framework\n' > "$safe_project"
if Scripts/check-no-networking.sh "$safe_source" "$safe_project" >/dev/null 2>&1; then
  echo "Networking guardrail self-test failed to reject Network.framework." >&2
  exit 1
fi

echo "Networking guardrail self-test passed."
