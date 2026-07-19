#!/usr/bin/env bash

set -euo pipefail

source_root="${1:-Hearth/Hearth}"
project_file="${2:-Hearth/Hearth.xcodeproj/project.pbxproj}"
forbidden_pattern='URLSession|Network\.framework|NWConnection|import[[:space:]]+Network'
found_violation=0

if [[ ! -d "$source_root" ]]; then
  echo "Networking guardrail: source directory not found: $source_root" >&2
  exit 2
fi

if grep -RInE --include='*.swift' "$forbidden_pattern" "$source_root"; then
  found_violation=1
fi

if [[ "$project_file" != "-" ]]; then
  if [[ ! -f "$project_file" ]]; then
    echo "Networking guardrail: project file not found: $project_file" >&2
    exit 2
  fi

  if grep -nE "$forbidden_pattern" "$project_file"; then
    found_violation=1
  fi
fi

if [[ "$found_violation" -ne 0 ]]; then
  echo "Networking guardrail failed: Hearth product code must remain fully offline." >&2
  exit 1
fi

echo "Networking guardrail passed."
