#!/usr/bin/env bash
# Keeps pik.yaml in step with the template that pik add copies.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

from=$(sed -n 's/^  from: //p' pik.yaml)
[[ $from == template ]] || {
  echo "FAIL: pik.yaml add.from is \"$from\", not template" >&2
  exit 1
}
[[ -x template/.agents/check.sh ]] || {
  echo 'FAIL: template/.agents/check.sh, which pik.yaml runs, is missing or not executable' >&2
  exit 1
}
echo 'ok - pik.yaml copies the template and runs its check'
