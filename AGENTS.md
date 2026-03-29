# Agent Instructions

## Repository Overview

This repository is a **metadata-driven dotfiles repo**.

- Installable config lives under `packages/shared`, `packages/linux`, and `packages/macos`
- Each package owns its own `setup.yaml`, `is_stowed.sh`, optional `setup.sh`, optional docs, and deployable payload under `stow/`
- The root entrypoint is `./setup.sh`
- The actual engine is `scripts/dotfiles.rb`
- Package-local entrypoints delegate through `scripts/package-run.sh`

GNU Stow is no longer the default source of truth. The native linker defined in `scripts/dotfiles.rb` is the primary setup path, though the engine still supports `engine: stow` for packages that explicitly opt into it.

## Core Commands

### Setup and Inspection

```bash
./setup.sh
./setup.sh --dry-run
./setup.sh --check
./setup.sh --list
./setup.sh --package zed
./setup.sh --package linux/hyprland
```

### Task Runner

```bash
just
just list
just dry-run
just check
just smoke
```

### Code Quality

```bash
mise exec ruby -- ruby -c scripts/dotfiles.rb
shellcheck setup.sh stow-platform.sh check-installed-packages.sh scripts/package-run.sh scripts/tests/smoke.sh packages/*/*/*.sh
```

### Targeted Validation

```bash
bash scripts/tests/smoke.sh
packages/shared/zed/setup.sh --dry-run
packages/shared/zed/is_stowed.sh
```

## File Organization

### Root

- `setup.sh`: thin Bash entrypoint with optional Gum styling
- `scripts/dotfiles.rb`: metadata-driven package discovery, linking, hooks, installs, checks
- `scripts/package-run.sh`: package-local delegator back to the root engine
- `docs/guide`: current operational docs
- `docs/reference`: focused references
- `docs/history`: historical migration/audit notes that may describe old layouts

### Package Shape

Every package should follow this layout:

```text
packages/<scope>/<name>/
├── setup.yaml
├── is_stowed.sh
├── setup.sh          # optional hook handler and package-local entrypoint
├── README.md         # optional package notes
├── docs/             # optional deeper package docs
└── stow/             # deployable payload only
```

### Package Semantics

- `setup.yaml` declares package state, selectors, install metadata, links, and hooks
- `is_stowed.sh` is authoritative and must exit `0` only when the package is correctly wired for its real behavior
- `setup.sh` should only handle package-specific side effects like `post_link` hooks; otherwise it should delegate to `scripts/package-run.sh`
- `stow/` must contain only tracked deployable payload
- Local machine-only files should stay out of `stow/`, usually under a gitignored `local/` directory beside the package

## Code Style Guidelines

### General

- Prefer small, explicit, idempotent changes
- Keep docs aligned with the actual engine behavior in `scripts/dotfiles.rb`
- Preserve the package contract: package-local metadata and checks should be readable without searching the whole repo
- Prefer editing the minimum set of files necessary to keep the structure obvious

### Ruby

- Use `#!/usr/bin/env ruby`
- Include `# frozen_string_literal: true`
- Prefer clear, standard-library-first Ruby
- Keep CLI behavior predictable and side effects explicit

### Bash

- Always use `set -euo pipefail`
- Make hooks idempotent
- Respect `DOTFILES_HOME`, `DOTFILES_OS`, `DOTFILES_DISTRO`, `DOTFILES_DESKTOP`, and `DOTFILES_YES` when relevant
- Use package-local `setup.sh` only for side effects that do not belong in generic linking

### Documentation

- Current docs belong in `docs/guide` or a package-local `README.md` / `docs/`
- Historical notes belong in `docs/history`
- Do not describe the repo as Stow-managed unless the specific package actually uses `engine: stow`
- If you change workflow semantics, update the canonical docs in `README.md`, `docs/README.md`, and `docs/guide/`

## Verification Checklist

Before finishing substantial changes:

- [ ] `mise exec ruby -- ruby -c scripts/dotfiles.rb`
- [ ] `./setup.sh --list`
- [ ] `./setup.sh --dry-run`
- [ ] `./setup.sh --check` or package-local `is_stowed.sh` where appropriate
- [ ] `bash scripts/tests/smoke.sh` for setup-flow changes
- [ ] Any package docs you touched still match their manifest and hook behavior

## Communication

- Be direct and specific
- Prefer file-backed facts over assumptions
- Call out stale docs or misleading structure explicitly
- When reviewing, focus first on correctness, reliability, readability, and maintenance risk
