# Shell Configuration Structure Reference

This document describes the internal shell-module layout used by the Bash and Zsh packages. It is not the overall repository layout.

For the repository-wide model, start with:

- [../README.md](../README.md)
- [../guide/HOW_IT_WORKS.md](../guide/HOW_IT_WORKS.md)
- [../guide/PACKAGE_CONTRACT.md](../guide/PACKAGE_CONTRACT.md)

## Where This Applies

- Linux Bash package: `packages/linux/bash`
- macOS Zsh package: `packages/macos/zsh`

## Bash Package Layout

```text
stow/
├── .bashrc
└── .config/
    └── bash/
        ├── bashrc
        ├── functions.d/
        └── modules/
            ├── 0-system/
            ├── 1-lang/
            └── 2-editor/
```

## Zsh Package Layout

```text
stow/
├── .zshrc
├── .fzf.zsh
└── .config/
    └── zsh/
        ├── zshrc
        └── modules/
            ├── 0-system/
            ├── 1-lang/
            └── 2-editor/
```

## Module Loading Model

Both shell packages use the same basic idea:

1. A top-level rc file is linked into `$HOME`.
2. That rc file sources the shell-specific loader under `.config/<shell>/`.
3. The loader recursively sources module files in directory order.
4. Module directories are numbered to keep load order predictable.

Typical order:

- `0-system/`: platform setup, prompt, shell behavior, aliases, functions
- `1-lang/`: language runtimes and version managers
- `2-editor/`: editor and development tool integration

## Conventions

- Keep modules small and single-purpose.
- Use numeric prefixes when load order matters.
- Keep platform checks inside the relevant module when behavior differs across systems.
- Prefer adding a focused module over extending a generic `misc` file.

## Debugging

To debug module loading, enable debug output in the relevant shell and source the rc file again:

```bash
export DEBUG=true
source ~/.bashrc
```

```zsh
export DEBUG=true
source ~/.zshrc
```

## Related Package Docs

- [../../packages/linux/bash/README.md](../../packages/linux/bash/README.md)
- [../../packages/macos/zsh/README.md](../../packages/macos/zsh/README.md)
