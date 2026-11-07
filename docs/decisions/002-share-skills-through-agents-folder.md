# 002. Share skills through the .agents folder

- **Status**: accepted
- **Context**: Agents look for skills in different folders. Claude Code reads `.claude/skills/`, while tools such as Codex read `.agents/skills/`. Copies in both would drift.
- **Decision**: Keep each skill in `.agents/skills/`, and link it from `.claude/skills/` with a per-skill symlink.
- **Consequences**:
  - Each skill has one source, and the check fails if a link is missing or broken.
  - Symlinks need Developer Mode or `core.symlinks` on Windows, so the installer doesn't support Windows without them.
