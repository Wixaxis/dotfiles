---
name: add-omarchy-config
description: Add or change a personal Omarchy preference in this dotfiles repository. Use when a request should become an idempotent operation in scripts/omarchy-setup.rb, including Omarchy shell/bar, Hyprland, themes, fonts, terminals, applications, hooks, or other user configuration.
---

# Add Omarchy Config

Turn a requested preference into a small, repeatable operation in
`scripts/omarchy-setup.rb` using Omarchy's supported interface.

## Workflow

1. Read `/usr/share/omarchy/default/agents/skills/omarchy/SKILL.md` completely.
2. Read its matching topic guide, when one exists.
3. Inspect the current user state and the relevant code in
   `scripts/omarchy-setup.rb`.
4. Discover the supported mechanism in this order:
   - Search `omarchy commands --json` for a matching command.
   - Read `omarchy <group> <action> --help`.
   - Read the command implementation with `command -v omarchy-...` when behavior
     or idempotence is unclear.
   - Read the relevant default under `/usr/share/omarchy/` when a user config
     edit is required.
   - Use current official upstream documentation only when local Omarchy sources
     are insufficient. Window rules always require the current Hyprland wiki.
5. Choose the narrowest supported method:
   - Prefer `omarchy ...` commands.
   - Otherwise edit a user-owned file under `~/.config/`.
   - Never edit or copy broad configuration from `/usr/share/omarchy/`.
6. Add an explicit state check and mutation to `scripts/omarchy-setup.rb`.
7. Run the validations below. Do not apply new preferences to the live system
   unless the user asked to run setup.

## Script Design

- Keep one readable `ensure_*` method per logical preference or component.
- Keep desired values near the top as constants when they are user preferences.
- Group calls in `run` by shell, display, appearance, applications, then validation.
- Check actual state before mutating it.
- Respect `--dry-run` and `--check` through the existing helpers.
- Use `command` for mutations and `capture` for queries.
- Back up a user config before direct edits; use `backup(path)` once per run.
- Make direct edits structural or tightly anchored. Do not blindly append lines.
- Set `@hyprland_changed` for Hyprland Lua edits so reload and config-error
  validation runs after application.
- Extend existing helpers before adding duplicate command or UI plumbing.
- Keep Gum output to one short status line per preference.

## Validation

Run:

```bash
mise exec ruby -- ruby -c scripts/omarchy-setup.rb
./setup.sh --dry-run
./setup.sh --check
git diff --check
```

For a Hyprland change that was applied, also require clean output from:

```bash
hyprctl reload
hyprctl configerrors
```

Report the supported Omarchy mechanism chosen and the validation result briefly.
