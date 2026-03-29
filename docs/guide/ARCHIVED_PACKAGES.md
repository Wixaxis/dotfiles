# Archived Packages

Archived packages no longer live in a separate root folder.

They now stay beside active packages in the normal package tree and are marked with:

```yaml
state: archived
```

That keeps package history and payload in one place while ensuring `./setup.sh` skips them by default.

Current archived packages:

- `packages/shared/githubcli`
- `packages/linux/dunst`
- `packages/linux/kitty`
- `packages/linux/kvantum`
- `packages/linux/qimgv`
- `packages/linux/solaar`
