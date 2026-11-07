#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

for tool in actionlint git jq shellcheck; do
  command -v "$tool" >/dev/null || {
    echo "Missing required tool: $tool" >&2
    exit 1
  }
done

shellcheck -x install.sh scripts/*.sh tests/*.test.sh template/.agents/check.sh template/.githooks/pre-commit
actionlint .github/workflows/*.yml template/.github/workflows/*.yml
.github/scripts/check-repo-standards.sh

for test in tests/*.test.sh; do
  echo "== $test"
  "$test"
done
echo 'All checks passed'
