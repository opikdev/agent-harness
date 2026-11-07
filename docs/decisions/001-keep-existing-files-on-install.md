# 001. Keep existing files on install

- **Status**: accepted
- **Context**: The harness must install into any repo, and many repos already have an `AGENTS.md`, hooks, or docs. Overwriting them would destroy work.
- **Decision**: `install.sh` never replaces a file and never changes an existing `core.hooksPath`. It lists what it kept, then runs the check.
- **Consequences**:
  - Installing and reinstalling are both safe.
  - A kept file can fail the check, so the install exits non-zero until you fix it.
  - Updating an installed harness needs a separate path, which `pik update` will cover.
