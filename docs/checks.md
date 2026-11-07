# Check reference

`.agents/check.sh` reports every failure, then exits with status 1. It needs Bash and `jq`. Pass a repo path to check a repo other than its own.

The pre-commit hook runs the local copy for fast feedback. CI runs a pinned release of the check from this repo, so editing the local copy can't get a change past CI.

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
| Skills | Each skill is reachable at `.claude/skills/<name>/SKILL.md` |
| MCP | `.mcp.json` is JSON with an `mcpServers` object |
