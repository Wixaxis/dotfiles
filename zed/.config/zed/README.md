# Zed Config State

This package tracks the current attempt to make Zed feel as close as possible to `/Users/wixaxis/.config/nvim` without pretending that non-portable Neovim behaviors are solved when they are not.

Use this file as the short operational summary.
Use [`NEOVIM_TRANSFORMATION.md`](./NEOVIM_TRANSFORMATION.md) as the detailed parity tracker.

## Current Scope

Tracked config:

- [`settings.json`](./settings.json)
- [`keymap.json`](./keymap.json)
- [`tasks.json`](./tasks.json)
- [`NEOVIM_TRANSFORMATION.md`](./NEOVIM_TRANSFORMATION.md)

The current work has focused on:

- Getting the core editor feel closer to Neovim.
- Porting the highest-value muscle-memory bindings.
- Making the config actually hot-reload reliably with Stow.
- Being explicit about what is still only partial parity.

## What Is Done

- Vim mode is enabled.
- Which-key is enabled with a short delay.
- Relative line numbers, smartcase find, system clipboard, autosave, and `scrolloff`-style margin are enabled.
- Preview tabs are disabled so tabs behave more intentionally.
- Git gutter and inline blame are enabled.
- Ruby / ERB language server preferences have been ported.
- Pane navigation exists on both `ctrl-w h/j/k/l` and direct `ctrl-h/j/k/l`.
- Insert-mode `jj` and `jk` escape are configured.
- Insert-mode `ctrl-h/j/k/l` cursor movement is configured.
- Core leader mappings exist for file search, project search, diagnostics, git panel, diff, pinning, close item, theme picker, and project-panel toggling.
- Exact Neovim-style bindings were added for rename, code actions, format, references, type definition, hover, signature help, relative line number toggle, line blame toggle, and comment toggle.
- Visual-mode `space /` now comments selections correctly.
- A global `lazygit` task exists in `tasks.json`.
- Leader bindings were widened to workspace-level contexts so they work in more than just editable text.
- `~/.config/zed` is now a real directory containing symlinks to tracked files instead of being one symlinked directory. This matters for hot reload.

## Important Caveats

- Zed parity is still intentionally judged strictly. Native Zed support on a different key or with weaker UX is still only `PARTIAL`.
- `space e` is now a real toggle in more contexts, but true "open file from project panel and then auto-hide panel immediately" still does not appear to be exposed as a clean native action.
- Workspace-level leader bindings make the config much more usable in panels and previews, but context-specific behavior in Zed can still differ from Neovim.
- Which-key is enabled, but its usefulness depends on bindings being available in the active context. That was a major reason for broadening the leader bindings.
- Tests currently use Zed task/code-action approximations, not full Neotest parity.
- The package contains a concise state summary here and a deeper tracker in `NEOVIM_TRANSFORMATION.md`. The tracker still needs a proper full refresh to match every recent binding change.

## Findings

- The largest gap is no longer basic editor capability; it is workflow parity.
- Zed can cover a surprising amount of the "feel" of Neovim when bindings are moved onto existing native actions.
- Context selection matters a lot in Zed. A binding that works in an editor may not work in a project panel or preview unless it is also exposed at the workspace or panel level.
- Symlinking the whole `~/.config/zed` directory is a bad fit for reliable hot reload. Symlinking files inside a real `~/.config/zed` directory is the safer layout.
- Some remaining Neovim workflows are not missing because of laziness in config; they are missing because Zed does not expose a native equivalent that is honest to call parity.

## Still To Do

High priority:

- Refresh the detailed tracker so it matches the current config exactly.
- Re-test hot reload and confirm whether Zed now picks up direct file edits without requiring manual reload.
- Decide how strict to be about test workflow parity versus "good enough via tasks and code actions."

Next major parity targets:

- Session workflow.
- Tests workflow.
- Yank history.
- Floating terminal workflow.
- Exact insert-mode completion keybind parity.
- Visual whitespace workflow.
- Custom Slim / language-specific parity.

Lower-confidence or likely non-goals:

- Full Noice/Lualine-style UI parity.
- Exact Bufferline tab model parity.
- Plugin toggles that have no meaningful Zed equivalent.

## Why The Current Shape Makes Sense

The current config prioritizes the shortest path to a usable editor:

- First: make movement, search, commenting, LSP, tabs, and git feel familiar.
- Second: make those bindings work consistently across Zed contexts.
- Third: avoid false claims of parity for workflows Zed does not really support yet.

That gives a setup that is already much closer to Neovim in day-to-day use, while keeping the remaining gaps obvious instead of hidden.
