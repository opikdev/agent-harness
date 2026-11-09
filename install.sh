#!/usr/bin/env bash
set -euo pipefail

template="$(cd "$(dirname "${BASH_SOURCE[0]}")/template" && pwd -P)"

if [[ $# -ne 1 ]]; then
  echo 'Usage: install.sh <target-dir>' >&2
  exit 2
fi
if [[ ! -d $1 ]]; then
  echo "Target is not a directory: \"$1\"" >&2
  exit 1
fi
target=$(cd "$1" && pwd -P)

echo 'install.sh is deprecated and will be removed in a future release. Run pik add agent-harness instead, which also records the version in .pik.yaml for pik update.' >&2

while IFS= read -r path; do
  if [[ -e $target/$path || -L $target/$path ]]; then
    echo "kept   $path"
    continue
  fi
  mkdir -p "$(dirname "$target/$path")"
  cp -P "$template/$path" "$target/$path"
  echo "added  $path"
done < <(cd "$template" && find . \( -type f -o -type l \) ! -name .DS_Store | sed 's|^\./||' | LC_ALL=C sort)

if [[ $(git -C "$target" rev-parse --show-toplevel 2>/dev/null) == "$target" ]]; then
  hooks_path=$(git -C "$target" config --get core.hooksPath || true)
  if [[ -z $hooks_path ]]; then
    git -C "$target" config core.hooksPath .githooks
    echo 'Enabled the pre-commit hook'
  elif [[ $hooks_path != .githooks ]]; then
    echo "core.hooksPath is already \"$hooks_path\", so call .agents/check.sh from your own pre-commit hook"
  fi
else
  echo 'Not a Git repo root, so run this after git init: git config core.hooksPath .githooks'
fi

"$target/.agents/check.sh"
echo 'Next: describe your project in docs/architecture.md and add your commands to AGENTS.md'
