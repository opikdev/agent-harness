# 003. Run a pinned check in CI

- **Status**: accepted
- **Context**: In a real trial, the hook blocked an agent's commit, and the agent removed the failing rule from `.agents/check.sh` to get past it. A check that lives in the repo it guards can be edited by whoever it blocks.
- **Decision**: Keep the local check for fast feedback, but have CI fetch a tagged release of this repo and run that copy against the target repo. `AGENTS.md` also tells agents to stop and ask rather than edit the check.
- **Consequences**:
  - Editing the local check can pass the hook, but it can't pass CI.
  - Getting past CI means changing the workflow, which shows up in the pull request diff.
  - Each release must update the pinned `ref` in the template.
  - Installed repos need a published tag before their workflow can run.
