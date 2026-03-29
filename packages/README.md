# Packages

The package tree is the installable part of this repository.

## Scopes

- `shared/`: packages that can apply on multiple systems
- `linux/`: Linux-only packages
- `macos/`: macOS-only packages

## How To Read A Package

When you open a package, read it in this order:

1. `setup.yaml`
2. `is_stowed.sh`
3. `setup.sh` if present
4. `README.md` and `docs/`
5. `stow/`

That gives you the package contract, the authoritative correctness check, any special side effects, the operational notes, and finally the deployable payload.

## Common Patterns

- Most packages use `mode: children` to keep the target directory real and symlink only tracked contents into it.
- Top-level files like `.bashrc` or `.zshrc` use `mode: file`.
- Packages with hook side effects implement them in `setup.sh` and declare them under `hooks:` in `setup.yaml`.
- Packages with extra correctness needs extend `is_stowed.sh` beyond the generic check.

## Good Examples

- `shared/zed`: demonstrates why `children` mode matters for hot reload
- `shared/ssh`: demonstrates a `post_link` hook plus an authoritative package check
- `shared/nushell`: demonstrates per-link selectors for macOS-specific wrapper files
- `macos/truenas-macos`: demonstrates local-only env handling plus a package hook

## Commands

```bash
./setup.sh --package zed
./setup.sh --package linux/hyprland --dry-run
./setup.sh --package ssh --check
```
