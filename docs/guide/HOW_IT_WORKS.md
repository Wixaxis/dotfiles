# How The Setup System Works

This document describes the actual workflow implemented by `./setup.sh` and `scripts/dotfiles.rb`.

## Entry Points

- `./setup.sh`: root shell entrypoint with optional Gum styling
- `scripts/dotfiles.rb`: metadata-driven engine
- `scripts/package-run.sh`: package-local delegator back to the root engine
- `packages/<scope>/<name>/setup.sh`: optional package-local entrypoint and hook handler

For normal use, start at the root:

```bash
./setup.sh
./setup.sh --dry-run
./setup.sh --check
./setup.sh --package zed
./setup.sh --package linux/hyprland
```

For package-local use, run the package entrypoint:

```bash
packages/shared/zed/setup.sh --dry-run
packages/shared/ssh/is_stowed.sh
```

## Detection And Selection

The engine detects:

- OS: `linux` or `macos`
- distro: for example `arch` or `macos`
- desktop: `hyprland`, `gnome`, `other`, or `none`
- home directory: from `DOTFILES_HOME` or `$HOME`

Package discovery scans `packages/*/*/setup.yaml`.

A package is applied only when:

- `state: active`
- package-level `applies_when` matches the detected context
- any `--package` filters match the package name or `scope/name`

Archived and disabled packages remain discoverable, but they are skipped by the normal apply flow.

## Install Metadata

Before linking, the engine can offer to install missing dependencies using the current platform section in `setup.yaml`.

Supported managers in v1:

- `paru`
- `pacman`
- `brew`

If `install: {}` is present, that means the package currently has no package-manager install step tracked in the manifest. Any manual or external dependency notes should live in that package’s README.

Use `--no-install` to skip dependency prompts.

## Linking

Each package declares a flat list of `links`.

Every link entry contains:

- `source`: path inside the package
- `target`: destination under the target home
- `mode`: `file`, `tree`, or `children`
- `create_parents`: whether parent directories should be created
- `backup_on_conflict`: whether conflicting targets may be moved aside after confirmation
- optional `applies_when`: extra selectors for that specific link

### `file`

Symlink one source file to one target path.

Use this for top-level files such as `~/.bashrc` or `~/.zshrc`.

### `tree`

Symlink one source path directly to one target path.

Use this only when a package really needs a whole path to be a symlink.

### `children`

Keep the target directory real, create tracked subdirectories as real directories, and symlink tracked files into them recursively.

This is the default mode because it avoids the old all-or-nothing directory symlink behavior while preserving direct file symlinks where apps need them. Zed is the main canary for this: `~/.config/zed` stays a real directory, while tracked files inside it remain direct symlinks so hot reload works.

## Conflicts And Backups

If a target already exists and is not the correct symlink, the engine treats it as a conflict.

When `backup_on_conflict: true`:

- the user is prompted before replacement
- the existing path is moved aside to `*.pre-dotfiles-YYYYMMDD-HHMMSS`

When `backup_on_conflict: false`:

- the package fails instead of mutating the target

## Hooks

Packages may declare hook phases in `setup.yaml`.

Supported phases in v1:

- `pre_link`
- `post_link`

When a phase is listed and `setup.sh` exists, the engine runs:

```bash
packages/<scope>/<name>/setup.sh <phase>
```

Current examples:

- `shared/ssh` uses `post_link` to ensure `Include ~/.ssh/dotfiles.conf` exists in `~/.ssh/config`
- `macos/truenas-macos` uses `post_link` to create a local env file from the example and optionally bootstrap the LaunchAgent

## Checks

After apply, each package is verified.

- In this repository, packages are expected to provide `is_stowed.sh`.
- `is_stowed.sh` is authoritative.
- The engine can fall back to a manifest-based generic check as a compatibility safety net, but that is not the normal authoring model.

The generic check verifies only that manifest-declared links are wired correctly. Package-specific behaviors such as include lines, copied env files, or service bootstrap expectations belong in `is_stowed.sh`.

## Environment Overrides

These environment variables are supported and are especially useful for tests:

- `DOTFILES_HOME`
- `DOTFILES_OS`
- `DOTFILES_DISTRO`
- `DOTFILES_DESKTOP`
- `DOTFILES_YES`

The smoke test uses those overrides to validate macOS, Linux, and Hyprland flows against temporary fake homes.

## Wrapper Scripts

- `setup.sh`: compatibility shell entrypoint
- `stow-platform.sh`: compatibility wrapper around `./setup.sh`
- `check-installed-packages.sh`: compatibility wrapper around `./setup.sh --check`

These wrappers exist so older habits do not break immediately, but the canonical workflow is the metadata-driven one documented here.
