# Changelog

All notable changes to this repo are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- The check fails when the harness workflow is missing, doesn't run the pinned check, or pins a branch or partial tag, and when the pre-commit hook is missing, not executable, or doesn't run the check.
- The README tells you to make the `harness` check required.
- The check reference says the hook checks the working tree, not the staged files, and doesn't run your project's lint or tests.

### Fixed

- The check fails when `.claude/skills/<name>` is a copy that differs from `.agents/skills/<name>`. Before, any `SKILL.md` there passed. Identical copies still pass.
- The harness workflow now runs the v0.2.0 check, not v0.1.0. A test fails when the pinned `ref` isn't the latest release in this changelog.

## [0.2.0] - 2026-11-08

### Added

- `pik.yaml`, so `pik add agent-harness` can add the harness to any repo.

## [0.1.0] - 2026-11-07

### Added

- `install.sh`, which adds the harness to any repo without overwriting existing files.
- Project map, architecture page, decision records, skills, and MCP config.
- `.agents/check.sh`, run by a pre-commit hook and, as a pinned copy, by CI.
