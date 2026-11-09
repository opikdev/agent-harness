# Agent guide

Adds a project map, agent skills, and enforced checks to any repo. This repo is part of the [starters](https://github.com/opikdev/starters) catalog.

| Path | Purpose |
|---|---|
| `install.sh` | Deprecated installer that copies `template/` into a target repo |
| `template/` | The files a target repo receives |
| `tests/` | Tests for the installer and the installed check |
| `docs/` | [Check reference](docs/checks.md) and [decisions](docs/decisions/) |

## Rules

- Run `scripts/check.sh` before calling work done. CI runs the same command.
- Keep `template/` stack-agnostic. It can depend on Bash, Git, and `jq`, and nothing else.
- Never make `install.sh` overwrite a file in the target repo.
- Add a test for every new rule in `template/.agents/check.sh`, and update [docs/checks.md](docs/checks.md).
- When you release, add the version to `CHANGELOG.md` and set the pinned `ref` in `template/.github/workflows/harness.yml` to the new tag in the same commit, then tag that commit. `tests/check.test.sh` fails if they differ. See [ADR 004](docs/decisions/004-pin-the-ci-check-by-release-tag.md).
- Record significant decisions as ADRs in `docs/decisions/`.
