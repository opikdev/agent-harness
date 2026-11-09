# 005. Deprecate install.sh in favor of pik add

- **Status**: accepted
- **Context**: `install.sh` repeats what `pik add` does, copying missing files and turning on the hook, but writes no `addons` record to `.pik.yaml`, so `pik update` can't find the harness. Writing that record from Bash means merging YAML into a file pik owns without a YAML parser, and a clone may sit on a commit that isn't a release, so there's no version to record.
- **Decision**: Keep `install.sh` working, but have it warn that it's deprecated and point to `pik add agent-harness`. Remove it in a later release.
- **Consequences**:
  - pik is the one install path that records the version, so updates have one source.
  - A repo installed with `install.sh` has no record. Run `pik add agent-harness` there to write one, which keeps every existing file.
  - `tests/install.test.sh` keeps covering `install.sh` until it's removed.
