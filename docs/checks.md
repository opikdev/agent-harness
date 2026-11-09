# Check reference

`.agents/check.sh` reports every failure, then exits with status 1. It needs Bash and `jq`. Pass a repo path to check a repo other than its own.

The pre-commit hook runs the local copy for fast feedback. CI runs a pinned release of the check from this repo, so editing the local copy can't get a change past CI.

## Rules

| Area | Rule |
|---|---|
| Agent files | `AGENTS.md` exists and has at most 100 lines |
| Agent files | `CLAUDE.md` exists, mentions `AGENTS.md`, and has at most 5 lines |
| Links | Relative links in `AGENTS.md`, `CLAUDE.md`, `docs/`, and `.agents/skills/` resolve |
| Docs | `docs/architecture.md` and `docs/decisions/` exist |
| Decisions | Each file except `README.md` is named `NNN-short-title.md` |
| Decisions | Each file has Status, Context, Decision, and Consequences fields |
| Decisions | No two files share a number |
| Skills | Each skill has a `SKILL.md` whose `name` matches its folder, plus a `description` |
| Skills | `.claude/skills/<name>` links to `.agents/skills/<name>`, or is an identical copy of it, such as on Windows without symlinks |
| Enforcement | `.github/workflows/harness.yml` exists, checks out `opikdev/agent-harness`, and runs its `template/.agents/check.sh` |
| Enforcement | That checkout pins `ref` to a release tag (`vX.Y.Z`) or a 40-character commit SHA, never a branch or a partial tag such as `v1` |
| Enforcement | `.githooks/pre-commit` exists, is executable, and runs `.agents/check.sh` |
| MCP | `.mcp.json` is JSON with an `mcpServers` object |

## Limits

- The hook runs only `.agents/check.sh`, not your project's lint, type checks, or tests. Run those in CI.
- The hook checks your working tree, not what you staged. An unstaged fix can let a broken commit through, and an unstaged break can block a good one. CI checks the committed files, so it catches what the hook misses.
- Checking the staged snapshot would mean copying the whole index on each commit, which is slow in large repos and runs filters such as Git LFS, so the hook doesn't.
- The rules can't catch a deleted workflow in CI, because a deleted workflow never runs. Make the `harness` job a required status check on your default branch, so a pull request that removes or renames it can't merge. See the [README](../README.md#usage).
