#!/usr/bin/env bash
# shellcheck source=tests/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

adr=docs/decisions/000-adopt-agent-harness.md

fresh() {
  cd "$sandbox"
  new_target
  "$root/install.sh" "$target" >/dev/null
  cd "$target"
}

check() {
  "$target/.agents/check.sh" 2>&1
}

expect_pass() {
  local label=$1 mutation=$2
  fresh
  eval "$mutation"
  check >/dev/null || fail "$label: $(check)"
  pass "allows $label"
}

expect_fail() {
  local label=$1 message=$2 mutation=$3 output
  fresh
  eval "$mutation"
  if output=$(check); then
    fail "$label: expected failure"
  fi
  [[ $output == *"$message"* ]] || fail "$label: got \"$output\""
  pass "catches $label"
}

expect_pass 'a fresh install' ':'
expect_fail 'a missing AGENTS.md' 'AGENTS.md is missing' 'rm AGENTS.md'
expect_pass 'an AGENTS.md of exactly 100 lines' 'seq 1 100 >AGENTS.md'
expect_fail 'an AGENTS.md of 101 lines' 'over 100 lines' 'seq 1 101 >AGENTS.md'
expect_fail 'a missing CLAUDE.md' 'CLAUDE.md is missing' 'rm CLAUDE.md'
expect_fail 'a CLAUDE.md with no pointer' 'must point to AGENTS.md' 'echo rules >CLAUDE.md'
expect_pass 'a CLAUDE.md of exactly 5 lines' '{ echo @AGENTS.md; seq 1 4; } >CLAUDE.md'
expect_fail 'a CLAUDE.md of 6 lines' 'over 5 lines' '{ echo @AGENTS.md; seq 1 5; } >CLAUDE.md'

expect_fail 'a broken link in AGENTS.md' 'links to missing "nope.md"' 'echo "[a](nope.md)" >>AGENTS.md'
expect_fail 'a broken link in docs' 'links to missing "gone.md"' 'echo "[a](gone.md)" >>docs/architecture.md'
expect_fail 'a broken link in a skill' 'links to missing' 'echo "[a](gone.md)" >>.agents/skills/verify-change/SKILL.md'
expect_fail 'a broken link with an anchor' 'links to missing "gone.md#part"' 'echo "[a](gone.md#part)" >>AGENTS.md'
expect_pass 'external, anchor, and titled links' 'echo "[a](https://example.com) [b](#rules) [c](mailto:a@example.com) [d](docs/architecture.md \"Title\")" >>AGENTS.md'

expect_fail 'a missing architecture doc' 'docs/architecture.md is missing' 'sed -i.bak "/architecture.md/d" AGENTS.md; rm AGENTS.md.bak docs/architecture.md'
expect_fail 'a missing decisions folder' 'docs/decisions/ is missing' 'sed -i.bak "/decisions/d" AGENTS.md; rm AGENTS.md.bak; rm -r docs/decisions'
expect_fail 'a misnamed ADR' 'must be named NNN-short-title.md' "mv $adr docs/decisions/adopt.md"
for field in Status Context Decision Consequences; do
  expect_fail "an ADR with no $field" "has no $field field" "sed -i.bak '/\*\*$field\*\*/d' $adr; rm $adr.bak"
done
expect_fail 'a duplicate ADR number' 'two ADRs numbered 000' "cp $adr docs/decisions/000-other.md"
expect_pass 'a README in the decisions folder' 'echo "# Decisions" >docs/decisions/README.md'

expect_fail 'a skill with no SKILL.md' 'has no SKILL.md' 'mkdir .agents/skills/empty'
expect_fail 'a skill with the wrong name' 'must set name: verify-change' 'sed -i.bak "s/^name: .*/name: other/" .agents/skills/verify-change/SKILL.md; rm .agents/skills/verify-change/SKILL.md.bak'
expect_fail 'a skill with no description' 'needs a description' 'sed -i.bak "/^description:/d" .agents/skills/verify-change/SKILL.md; rm .agents/skills/verify-change/SKILL.md.bak'
expect_fail 'a skill with no Claude link' '.claude/skills/verify-change must link' 'rm .claude/skills/verify-change'
expect_fail 'a broken Claude link' '.claude/skills/verify-change must link' 'rm .claude/skills/verify-change; ln -s ../../nowhere .claude/skills/verify-change'

workflow_file=.github/workflows/harness.yml
sha=0123456789abcdef0123456789abcdef01234567
expect_fail 'a missing harness workflow' "$workflow_file is missing" "rm $workflow_file"
expect_fail 'a workflow that fetches another repo' 'must check out opikdev/agent-harness' "sed -i.bak 's|opikdev/agent-harness|someone/fork|' $workflow_file; rm $workflow_file.bak"
expect_fail 'a workflow pinned to a branch' 'must pin ref' "sed -i.bak 's/ref: .*/ref: main/' $workflow_file; rm $workflow_file.bak"
expect_fail 'a workflow pinned to a major tag' 'must pin ref' "sed -i.bak 's/ref: .*/ref: v1/' $workflow_file; rm $workflow_file.bak"
expect_fail 'a workflow pinned to a short SHA' 'must pin ref' "sed -i.bak 's/ref: .*/ref: 0123456/' $workflow_file; rm $workflow_file.bak"
expect_pass 'a workflow pinned to a commit SHA' "sed -i.bak 's/ref: .*/ref: $sha # v1.2.3/' $workflow_file; rm $workflow_file.bak"
expect_fail 'a workflow that runs the local check' 'must run .harness/template/.agents/check.sh' "sed -i.bak 's|run: .harness/template/|run: |' $workflow_file; rm $workflow_file.bak"
expect_fail 'a missing pre-commit hook' '.githooks/pre-commit is missing' 'rm .githooks/pre-commit'
expect_fail 'a pre-commit hook that is not executable' 'must be executable' 'chmod -x .githooks/pre-commit'
expect_fail 'a pre-commit hook that skips the check' 'must run .agents/check.sh' 'printf "#!/bin/sh\nexit 0\n" >.githooks/pre-commit'

expect_fail 'a missing .mcp.json' '.mcp.json is missing' 'rm .mcp.json'
expect_fail 'invalid .mcp.json' 'must be JSON' 'echo "{" >.mcp.json'
expect_fail '.mcp.json with no servers object' 'must be JSON' 'echo "{\"mcpServers\": []}" >.mcp.json'

fresh
rm AGENTS.md CLAUDE.md .mcp.json
output=$(check) && fail 'expected failure'
[[ $output == *'failed with 3 error(s)'* ]] || fail "got \"$output\""
pass 'reports every error, not just the first'

fresh
rm CLAUDE.md
sed -i.bak '2i\
exit 0
' .agents/check.sh
rm .agents/check.sh.bak
.agents/check.sh >/dev/null || fail 'the weakened local check should pass'
if output=$(cd "$sandbox" && "$root/template/.agents/check.sh" "$target" 2>&1); then
  fail 'pinned check should ignore a weakened local copy'
fi
[[ $output == *'CLAUDE.md is missing'* ]] || fail "got \"$output\""
pass 'a pinned check run against the repo ignores a weakened local copy'

workflow="$root/template/.github/workflows/harness.yml"
grep -q 'repository: opikdev/agent-harness' "$workflow" || fail 'workflow does not fetch the pinned harness'
latest=$(grep -m 1 -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' "$root/CHANGELOG.md")
latest=${latest#'## ['}
latest=${latest%]}
grep -qE "^ +ref: v$latest$" "$workflow" || fail "workflow does not pin v$latest, the latest release in CHANGELOG.md"
grep -q 'run: .harness/template/.agents/check.sh "' "$workflow" || fail 'workflow runs the local check'
pass 'CI runs the check pinned to the latest release, not the local copy'
