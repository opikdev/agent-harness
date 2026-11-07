#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
sandbox=$(cd "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$sandbox"' EXIT

export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL="$sandbox/gitconfig"
git config --global user.name test
git config --global user.email test@example.com
git config --global init.defaultBranch main

target="$sandbox/target"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

pass() {
  echo "ok - $1"
}

new_target() {
  rm -rf "$target"
  mkdir -p "$target"
}

new_git_target() {
  new_target
  git -C "$target" init --quiet
}
