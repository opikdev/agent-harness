# Agent harness

Give coding agents a project map, reusable skills, and enforced checks in any repo, in any stack. Agents start each session knowing nothing about your project, so the harness keeps your instructions in one place and fails the commit when they break.

[![CI](https://github.com/opikdev/agent-harness/actions/workflows/ci.yml/badge.svg)](https://github.com/opikdev/agent-harness/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

It's an add-on for a repo you already have, not a project template.

## Features

- **One map for every agent:** `AGENTS.md` is the shared guide, and `CLAUDE.md` points Claude Code to it.
- **Decision records:** `docs/decisions/` keeps the reasons behind your choices next to the code.
- **Reusable skills:** `record-decision` and `verify-change`, kept in `.agents/skills/` and linked from `.claude/skills/`.
- **Enforced structure:** a pre-commit hook and CI fail on broken links, incomplete decision records, and invalid skills. CI runs a pinned copy of the check, so an agent can't pass by editing the local one.
- **MCP config:** `.mcp.json` gives you one place to list project tools. It starts with no servers.
- **Safe to install:** it never overwrites your files, so you can run it on an existing repo.

## Quick start

You need Bash, Git, and `jq`. Clone this repo, then point the installer at your project:

```sh
git clone https://github.com/opikdev/agent-harness
agent-harness/install.sh path/to/your-repo
```

The installer lists what it added and kept, turns on the pre-commit hook, and runs the check. Nothing is committed for you, so review the new files first.

## Usage

After installing, make the map yours:

1. Describe your project in `docs/architecture.md`.
2. Add your setup, run, and test commands to `AGENTS.md`.
3. Commit the files.

Each new clone needs the hook turned on once:

```sh
git config core.hooksPath .githooks
```

Run the check at any time from your repo:

```sh
.agents/check.sh
```

See [what the check enforces](docs/checks.md). To add your own skill, create `.agents/skills/<name>/SKILL.md`, then link it from `.claude/skills/<name>`.

To work on the harness itself, run `scripts/check.sh`. It also needs `actionlint` and `shellcheck`.

## Project structure

| Path | Purpose |
|---|---|
| `install.sh` | Copies `template/` into a target repo |
| `template/` | The files a target repo receives |
| `tests/` | Tests for the installer and the installed check |
| `docs/` | Check reference and decisions |

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request, and follow the [code of conduct](CODE_OF_CONDUCT.md).

## Security

Report vulnerabilities privately, as described in [SECURITY.md](SECURITY.md).

## License

Released under the [MIT License](LICENSE).
