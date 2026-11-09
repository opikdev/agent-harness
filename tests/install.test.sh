#!/usr/bin/env bash
# shellcheck source=tests/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

expect_rejected() {
  local label=$1 code=$2 message=$3 actual=0 output
  shift 3
  output=$("$root/install.sh" "$@" 2>&1) || actual=$?
  [[ $actual == "$code" ]] || fail "$label: exit $actual"
  [[ $output == *"$message"* ]] || fail "$label: got \"$output\""
  pass "rejects $label"
}

expect_rejected 'no target' 2 'Usage: install.sh'
expect_rejected 'extra arguments' 2 'Usage: install.sh' a b
expect_rejected 'a missing target' 1 'Target is not a directory' "$sandbox/nope"
touch "$sandbox/file"
expect_rejected 'a file as target' 1 'Target is not a directory' "$sandbox/file"

new_git_target
output=$("$root/install.sh" "$target")
[[ $output == *'Harness check passed'* ]] || fail "got \"$output\""
[[ $output == *'Next: describe your project'* ]] || fail "got \"$output\""
pass 'installs into an empty repo and its checks pass'

new_git_target
warning=$("$root/install.sh" "$target" 2>&1 >/dev/null)
[[ $warning == *'install.sh is deprecated'*'pik add agent-harness'* ]] || fail "got \"$warning\""
[[ ! -e $target/.pik.yaml ]] || fail 'install.sh wrote .pik.yaml'
pass 'warns that it is deprecated in favor of pik add, and writes no .pik.yaml'

for path in AGENTS.md CLAUDE.md .mcp.json docs/architecture.md docs/decisions/000-adopt-agent-harness.md \
  .agents/skills/record-decision/SKILL.md .agents/skills/verify-change/SKILL.md \
  .githooks/pre-commit .github/workflows/harness.yml; do
  [[ -f $target/$path ]] || fail "$path was not installed"
done
pass 'installs the map, docs, skills, MCP config, hook, and workflow'

[[ -L $target/.claude/skills/verify-change ]] || fail 'Claude skill is not a symlink'
[[ -f $target/.claude/skills/verify-change/SKILL.md ]] || fail 'Claude skill link is broken'
pass 'links Claude skills to .agents/skills'

[[ -x $target/.agents/check.sh && -x $target/.githooks/pre-commit ]] || fail 'scripts are not executable'
pass 'keeps scripts executable'

[[ $(git -C "$target" config core.hooksPath) == .githooks ]] || fail 'hook not enabled'
pass 'enables the hook'

git -C "$target" rev-parse --verify HEAD >/dev/null 2>&1 && fail 'install made a commit'
pass 'leaves committing to you'

(cd "$target/docs" && ../.agents/check.sh >/dev/null) || fail 'check failed from a subdirectory'
pass 'check works from a subdirectory'

git -C "$target" add -A
git -C "$target" commit --quiet -m 'add harness' || fail 'hook blocked a valid commit'
pass 'hook allows a valid commit'

echo '[broken](missing.md)' >>"$target/AGENTS.md"
git -C "$target" add AGENTS.md
if git -C "$target" commit --quiet -m bad 2>/dev/null; then
  fail 'hook allowed a broken commit'
fi
pass 'hook blocks a broken commit'

new_git_target
echo '# Mine' >"$target/AGENTS.md"
mkdir -p "$target/.claude/skills/verify-change"
echo custom >"$target/.claude/skills/verify-change/SKILL.md"
if output=$("$root/install.sh" "$target" 2>&1); then
  fail 'a kept skill that differs from .agents/skills should fail the check'
fi
[[ $(cat "$target/AGENTS.md") == '# Mine' ]] || fail 'existing file was overwritten'
[[ $(cat "$target/.claude/skills/verify-change/SKILL.md") == custom ]] || fail 'existing skill was overwritten'
[[ $output == *'kept   AGENTS.md'* && $output == *'added  CLAUDE.md'* ]] || fail "got \"$output\""
[[ $output == *'.claude/skills/verify-change must link'* ]] || fail "got \"$output\""
pass 'keeps existing files and adds the rest'

before=$(cd "$target" && find . -path ./.git -prune -o -type f -print | sort | xargs cat | shasum)
"$root/install.sh" "$target" >/dev/null 2>&1 || true
after=$(cd "$target" && find . -path ./.git -prune -o -type f -print | sort | xargs cat | shasum)
[[ $before == "$after" ]] || fail 'second install changed files'
pass 'is safe to run twice'

new_git_target
git -C "$target" config core.hooksPath .husky
output=$("$root/install.sh" "$target")
[[ $(git -C "$target" config core.hooksPath) == .husky ]] || fail 'existing hooks path was replaced'
[[ $output == *'already ".husky"'* ]] || fail "got \"$output\""
pass 'keeps an existing hooks path'

new_target
output=$("$root/install.sh" "$target")
[[ $output == *'Not a Git repo root'* ]] || fail "got \"$output\""
pass 'installs outside a Git repo'

new_git_target
mkdir "$target/nested"
"$root/install.sh" "$target/nested" >/dev/null
[[ -z $(git -C "$target" config --get core.hooksPath) ]] || fail 'changed the enclosing repo'
pass 'leaves an enclosing repo alone'

new_git_target
seq 1 101 >"$target/AGENTS.md"
if output=$("$root/install.sh" "$target" 2>&1); then
  fail 'existing file that fails the check should fail the install'
fi
[[ $output == *'over 100 lines'* ]] || fail "got \"$output\""
pass 'reports when a kept file fails the check'
