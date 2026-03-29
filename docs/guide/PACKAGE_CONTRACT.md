# Package Contract

Every installable package in this repository should be understandable from its own directory.

## Required Shape

```text
packages/<scope>/<name>/
├── setup.yaml
├── is_stowed.sh
├── setup.sh          # optional
├── README.md         # optional
├── docs/             # optional
└── stow/
```

`stow/` is payload-only. Do not mix deployable files with package docs, notes, or local machine state.

## `setup.yaml`

Each package must have a manifest with these fields:

```yaml
name: example
description: Example package
state: active
engine: native
applies_when:
  os:
    - linux
install:
  arch:
    manager: paru
    packages:
      - example
links:
  - source: stow/.config
    target: ".config"
    mode: children
    create_parents: true
    backup_on_conflict: true
hooks:
  - post_link
```

### Required Fields

- `name`
- `description`
- `state`
- `links`

### Supported `state` Values

- `active`
- `disabled`
- `archived`

### Supported `engine` Values

- `native` for the metadata-driven linker
- `stow` only for packages that explicitly require GNU Stow behavior

If `engine` is omitted, the engine defaults to `native`.

### `applies_when`

Selectors supported in v1:

- `os`
- `distro`
- `desktop`

Selectors may be set on the package or on individual link entries.

### `install`

This is the package-manager source of truth for that package.

Supported platform keys in v1:

- distro keys such as `arch`
- OS keys such as `macos`

Supported managers in v1:

- `paru`
- `pacman`
- `brew`

Use `install: {}` when the package has no manifest-managed package-manager step. If the package still has manual dependencies, document them in the package README.

### `links`

Links are flat and explicit. Supported modes:

- `file`
- `tree`
- `children`

Use `children` by default for config directories.

## `is_stowed.sh`

This file is mandatory by repository convention and authoritative when present.

The engine can fall back to a manifest-only generic check, but packages in this repository should still provide `is_stowed.sh`.

It must exit `0` only when the package is correctly wired for the behavior that package actually needs.

Typical pattern:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$ROOT/scripts/package-run.sh" "$PACKAGE_DIR" --generic-check
```

Add extra checks when generic link validation is not enough.

Examples:

- `shared/ssh` also checks for `Include ~/.ssh/dotfiles.conf`
- `macos/truenas-macos` also checks for the local env file

## `setup.sh`

This file is optional.

Use it only for package-specific side effects that should not live in the generic linker.

Typical structure:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${1:-apply}" in
  post_link)
    # package-specific side effect
    ;;
  *)
    exec "$ROOT/scripts/package-run.sh" "$PACKAGE_DIR" "$@"
    ;;
esac
```

Supported hook phases in v1:

- `pre_link`
- `post_link`

## `README.md` And `docs/`

Package docs should answer:

- what this package manages
- any local-only files it expects
- any manual dependencies not modeled in `install`
- any hook side effects
- any special correctness constraints, such as why `children` mode is required

Put short operational notes in `README.md`.
Put deeper package-specific references in `docs/`.

## Local State

If a package needs repo-adjacent but untracked local state, keep it outside `stow/`, usually under a gitignored `local/` directory.

Examples:

- local Zed theme experiments
- local SSH notes or secrets that are not deployable payload

## Authoring Checklist

- Add `setup.yaml`
- Put tracked deployable files in `stow/`
- Add `is_stowed.sh`
- Add `setup.sh` only if the package needs hook behavior
- Add package docs if the package has manual steps or non-obvious behavior
- Verify with `./setup.sh --package <name> --dry-run`
- Verify with `./setup.sh --package <name> --check`
