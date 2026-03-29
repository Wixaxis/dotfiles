# Dotfiles

This repository is a metadata-driven dotfiles system. Deployable config lives under `packages/`; repo tooling and documentation stay at the root.

The shell entrypoint is `./setup.sh`. The actual setup engine is `scripts/dotfiles.rb`.

## Start Here

```bash
./setup.sh
./setup.sh --dry-run
./setup.sh --check
./setup.sh --list
./setup.sh --package zed
./setup.sh --package linux/hyprland
```

Repo tasks:

```bash
just
just list
just dry-run
just check
just smoke
```

## Repository Shape

- `packages/shared`, `packages/linux`, `packages/macos`: installable packages
- `packages/<scope>/<name>/stow`: deployable payload only
- `packages/<scope>/<name>/setup.yaml`: manifest with state, selectors, install metadata, links, and hooks
- `packages/<scope>/<name>/is_stowed.sh`: authoritative package check
- `packages/<scope>/<name>/setup.sh`: optional hook handler and package-local entrypoint
- `scripts/`: root orchestration, helpers, and smoke tests
- `docs/guide`: current operational docs
- `docs/reference`: focused technical references
- `docs/history`: migration and audit history that may describe older layouts

Archived packages stay in the normal tree and are marked with `state: archived`, so they are skipped by default.

## How Setup Works

1. Detect the current OS, distro, desktop, and target home directory.
2. Discover package manifests under `packages/`.
3. Select packages whose `state` is `active` and whose selectors match the current machine.
4. Optionally offer to install missing dependencies from manifest metadata.
5. Apply link intents and package hooks.
6. Verify each package with its own `is_stowed.sh`.

Every package in this repository is expected to ship `is_stowed.sh`. The engine still has a manifest-only fallback as a compatibility safety net, but that is not the package contract.

Supported link modes:

- `file`: symlink one file to one target
- `tree`: symlink one path directly
- `children`: keep the target directory real and symlink its tracked children into it

`children` is the default for most packages because it keeps config directories editable and hot-reload-friendly without forcing whole-directory symlinks.

## Canonical Docs

- [docs/README.md](docs/README.md): docs index and authority map
- [docs/guide/SETUP_GUIDE.md](docs/guide/SETUP_GUIDE.md): getting started and everyday commands
- [docs/guide/HOW_IT_WORKS.md](docs/guide/HOW_IT_WORKS.md): end-to-end setup workflow
- [docs/guide/PACKAGE_CONTRACT.md](docs/guide/PACKAGE_CONTRACT.md): package anatomy and authoring rules
- [packages/README.md](packages/README.md): how to read the package tree

## Notes

- GNU Stow is no longer the default source of truth. The native linker drives the repo by default, though the runner still supports `engine: stow` for packages that explicitly opt in.
- Package-local docs now sit beside the package instead of inside deployable payload.
- Local machine-only files should stay out of `stow/`. Keep them in a package-local ignored `local/` directory when they need to live beside the package.
