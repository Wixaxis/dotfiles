# Setup Guide

This is the quickest way to use the current metadata-driven system.

For the full workflow, see [HOW_IT_WORKS.md](HOW_IT_WORKS.md).
For package authoring rules, see [PACKAGE_CONTRACT.md](PACKAGE_CONTRACT.md).

## Prerequisites

- `ruby`
- `git`
- `gum` if you want styled prompts and confirmations
- Optional package managers referenced by manifests:
  - Arch Linux: `paru` or `pacman`
  - macOS: `brew`

## First Run

```bash
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
./setup.sh
```

## Everyday Commands

```bash
./setup.sh
./setup.sh --dry-run
./setup.sh --check
./setup.sh --list
./setup.sh --package zed
./setup.sh --package linux/hyprland
```

Use `--package <name>` or `--package <scope/name>` to narrow the run.

## What Happens On Apply

1. The engine detects OS, distro, desktop, and home directory.
2. It discovers `setup.yaml` files under `packages/`.
3. It keeps only `active` packages whose selectors match the machine.
4. It optionally offers to install missing dependencies described in the manifest.
5. It applies links and package hooks.
6. It verifies each package with `is_stowed.sh`.

The shell entrypoint is `./setup.sh`, but the workflow itself lives in `scripts/dotfiles.rb`.

## Validation

Use the root `justfile`:

```bash
just
just list
just dry-run
just check
just smoke
```

The smoke test creates temporary fake homes and exercises:

- macOS package flow
- Linux package flow
- Linux + Hyprland package flow
