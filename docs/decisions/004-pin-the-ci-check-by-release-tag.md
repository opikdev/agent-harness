# 004. Pin the CI check by release tag

- **Status**: accepted
- **Context**: The harness workflow fetches this repo at a pinned `ref` ([ADR 003](003-run-a-pinned-check-in-ci.md)). A commit SHA can't move, but a release commit can't contain its own SHA, so SHA pins would need a second commit after every release, and the tag would point at a commit other than the one it pins. v0.2.0 also shipped still pinning v0.1.0, because nothing checked the bump.
- **Decision**: Pin the full release tag, `vX.Y.Z`, in the release commit itself. A test fails when the pinned tag isn't the latest version in `CHANGELOG.md`. The installed check accepts a `vX.Y.Z` tag or a 40-character SHA, so a repo can pin harder, and rejects branches and partial tags such as `main` or `v1`.
- **Consequences**:
  - A release stays one commit, and its tag runs exactly the check it ships.
  - Forgetting the bump fails CI before the release merges.
  - A tag can still be moved by anyone who can push tags to this repo, so protect `v*` tags with a ruleset or immutable releases.
