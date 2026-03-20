# Neovim -> Zed Transformation Tracker

This file is the source of truth for migrating `/Users/wixaxis/.config/nvim` into Zed as far as Zed can honestly go.

The goal is not "does Zed have some built-in feature that smells similar?".
The goal is:

1. Keep the same workflow where possible.
2. Keep the same keybinds where possible.
3. Treat built-in Zed parity with a different keybind or weaker behavior as `PARTIAL`, not `DONE`.

## Status Legend

- `DONE`: same or near-identical workflow, and the active Zed config already gives the intended behavior with the same keybind or a very close equivalent.
- `PARTIAL`: Zed has the capability, but the keybind differs, the UX differs, or the current config only covers part of the workflow.
- `TODO`: not implemented in Zed config yet, or Zed parity is missing / unverified.

## Current Zed Config Scope

Tracked config files:

- [`settings.json`](./settings.json)
- [`keymap.json`](./keymap.json)

Current migration policy:

- Exact leader / workflow parity is preferred over "just use Zed defaults".
- If Zed has a native Vim binding but the Neovim keybind is different, keep the item as `PARTIAL`.
- This tracker is intentionally detailed so future threads can move items from `TODO` -> `PARTIAL` -> `DONE`.

## Current Snapshot

### DONE now

- Vim mode enabled.
- System clipboard integration enabled.
- Smartcase-style find enabled.
- Relative line numbers enabled.
- Scroll margin aligned with Neovim `scrolloff = 8`.
- No scrolling past EOF.
- Autosave after delay enabled.
- Preview-tab behavior disabled to make tabs behave more intentionally.
- Git gutter enabled.
- Inline git blame enabled.
- Project panel diagnostics visibility enabled.
- Explicit leader mappings for a small set of search / explorer / git / tab actions.
- `ctrl-w h/j/k/l` pane navigation added in Zed.

### PARTIAL now

- LSP parity is mixed: some motions exist natively in Zed Vim mode, but several keys differ from Neovim.
- Search/navigation parity is mixed: some leader prefixes exist, but Snacks pickers are only partially represented.
- Buffer/tab UX is only partially matched: Zed has tabs/items, not Bufferline.
- Git parity is partial: some native Zed Git Vim flows exist, but not on your current Neovim keys.
- Commenting is partial: feature exists, but your `<leader>/` binding is not yet mirrored.
- Treesitter motions/textobjects are often available in Zed Vim mode, but not all have been explicitly audited in config.

### TODO now

- Session workflow.
- Tests workflow.
- Yank history.
- LazyGit workflow.
- Floating terminal workflow.
- Which-key-style discoverability.
- AI / Sidekick workflows.
- Visual whitespace workflow.
- Most plugin toggles and plugin-specific commands.
- Exact insert-mode completion keybind parity.
- Custom Slim workflow parity.

## Full Feature Inventory

| Area | Neovim capability | Source | Status | Current Zed state | Next step |
| --- | --- | --- | --- | --- | --- |
| Core editor | `mapleader = " "` | `configs/core.lua` | `DONE` | `space`-prefixed sequences work in `keymap.json` | Keep all future custom maps under `space` namespaces |
| Core editor | Relative numbers by default | `configs/core.lua` | `DONE` | `relative_line_numbers = "enabled"` and Vim toggle enabled | Keep |
| Core editor | Clipboard = system | `configs/core.lua` | `DONE` | `vim.use_system_clipboard = "always"` | Keep |
| Core editor | Smartcase search | `configs/core.lua` | `DONE` | `vim.use_smartcase_find = true` | Keep |
| Core editor | Scrolloff 8 | `configs/core.lua` | `DONE` | `vertical_scroll_margin = 8` | Keep |
| Core editor | No swapfile | `configs/core.lua` | `DONE` | Zed does not expose Vim swapfile semantics in the same way | No action needed |
| Core editor | Undo file persistence | `configs/core.lua` | `PARTIAL` | Zed persists state/session, but not as Vim undo files | Accept as editor-model difference unless it hurts workflow |
| Core editor | `k/j` operate on wrapped lines | `configs/core.lua` | `TODO` | Not configured / not audited in Zed | Research whether Zed Vim can emulate this directly |
| Core editor | `<Esc>` clears search highlight | `configs/core.lua` | `TODO` | No equivalent mapping configured | Look for safe equivalent or accept difference |
| Core editor | Visual paste preserves unnamed register | `configs/core.lua` | `TODO` | Not implemented | Check whether Zed Vim can emulate this |
| Core editor | Hard tabs, width 2 | `configs/core.lua` | `PARTIAL` | Not explicitly ported yet in Zed global/language settings | Add per-language indentation policy if desired |
| Core editor | Auto-save after inactivity | `auto-save.nvim` | `DONE` | `autosave.after_delay.milliseconds = 1000` | Keep |
| Core editor | Better escape (`jj` / `jk`) | `better-escape.nvim` | `TODO` | Not configured | Add insert-mode escape sequence if desired |
| Core editor | Auto pairs | `autopairs.nvim` | `PARTIAL` | Zed has built-in editor pairing behavior, but no parity tracking/toggle | Decide whether built-in behavior is enough |
| Core editor | Current line highlight / cursorword emphasis | `nvim-cursorline.nvim` | `PARTIAL` | `current_line_highlight = "all"` exists; cursorword-style underline parity not configured | Check whether more visual tuning is needed |
| Core editor | Sleuth / indentation autodetect | `vim-sleuth` | `PARTIAL` | Zed has syntax-aware indent and language settings, but not explicit sleuth parity | Usually acceptable; verify on mixed-indent repos |
| Core editor | Transparent background | `transparent.nvim` | `TODO` | Not configured | Decide whether to port visually |
| UI | Theme pool / theme picker | `theme.lua`, Snacks picker | `PARTIAL` | Theme configured, but no leader theme selector parity | Add theme selector mapping if desired |
| UI | System dark/light switching | `auto-dark-mode.nvim` | `PARTIAL` | Zed theme uses `mode = "system"` | Good behavior, but no manual disable mapping like `<leader>000` |
| UI | Lualine-style statusline richness | `lualine.nvim`, `noice.nvim` | `TODO` | Zed has status surfaces, but not a direct equivalent | Likely accept editor difference |
| UI | Noice messaging/command UI | `noice.nvim` | `TODO` | Not represented in current Zed config | Accept as likely non-portable |
| UI | Render markdown / `.mdc` association | `render-markdown.nvim` | `TODO` | Not configured in Zed | Add file type association if needed |
| UI | TODO comments search | `todo-comments.nvim` | `TODO` | Not configured | Search extension / task / keymap option |
| UI | Visual whitespace toggle | `visual-whitespace.nvim` | `TODO` | Not configured | Research Zed support / extension |
| UI | Colorizer | `nvim-colorizer.lua` | `TODO` | Not audited in Zed config | Verify whether Zed already handles color decorators sufficiently |
| Search / nav | Snacks picker ecosystem | `snacks.nvim` | `PARTIAL` | Only a subset is represented with native Zed commands | Continue mapping picker-by-picker |
| Search / nav | Project panel / explorer | `snacks.explorer` | `PARTIAL` | `space e` and `space shift-e` exist | Add hidden/ignored explorer parity if possible |
| Search / nav | Project search multibuffer | `snacks.picker.grep` | `DONE` | `space f w` uses `pane::DeploySearch` | Keep |
| Search / nav | File finder | `snacks.picker.files` | `DONE` | `space f f` uses `file_finder::Toggle` | Keep |
| Search / nav | Oldfiles / recents | `snacks.picker.recent` | `TODO` | No mapping yet | Find a good Zed action or accept gap |
| Search / nav | Git-tracked file finder | `snacks.picker.git_files` | `TODO` | No mapping yet | Likely no perfect native parity |
| Search / nav | Hidden+ignored file finder | `snacks.picker.find_all` | `TODO` | No mapping yet | Investigate file finder filters |
| Search / nav | Current-file search picker | `snacks.picker.lines` | `TODO` | No mapping yet | Use buffer search or outline if acceptable |
| Search / nav | Diagnostics picker | `snacks.picker.diagnostics` | `PARTIAL` | `space q` opens diagnostics view, not a picker | Good enough for now, but not exact |
| Search / nav | Keymaps/help discovery | `snacks.picker.keymaps`, `which-key.nvim` | `TODO` | No equivalent workflow configured | Need a discoverability strategy |
| Search / nav | Outline / symbols | Treesitter + LSP + Snacks | `PARTIAL` | `space f h` and `space f s` exist, but not on exact Neovim semantics | Could add more symbol-specific bindings |
| Tabs / buffers | Buffer cycling on `Tab` / `S-Tab` | `bufferline.nvim` | `PARTIAL` | Bound to next/previous Zed item | Good approximation, but item != bufferline buffer |
| Tabs / buffers | Pin current buffer/tab | `bufferline.nvim` | `DONE` | `space b p` -> `pane::TogglePinTab` | Keep |
| Tabs / buffers | Rename current tab | `bufferline.nvim` | `TODO` | Not configured | Check if Zed exposes a rename-tab workflow |
| Tabs / buffers | New named tab | `bufferline.nvim` | `TODO` | Not configured | Zed tabs differ from Vim tabs; decide target UX |
| Tabs / buffers | Next/prev tab under leader | `bufferline.nvim` | `TODO` | Not configured | Decide whether to model tabs or items |
| Tabs / buffers | Close current buffer | `bufferline.nvim` | `DONE` | `space x` closes current item with `close_pinned: false` | Keep |
| Sessions | Project-local sessions in repo root | `resession.nvim`, `scope.nvim` | `TODO` | Not configured | Major future work item |
| Git | Gutter signs | `gitsigns.nvim` | `DONE` | Git gutter enabled in Zed settings | Keep |
| Git | Inline blame | `gitsigns.nvim` | `DONE` | Inline blame enabled with delay | Keep |
| Git | Hunk navigation / preview / revert | `gitsigns.nvim` | `PARTIAL` | Zed Vim has native Git motions and diff actions, but different keys/workflow | Decide whether to remap toward Neovim |
| Git | Git status picker | Snacks Git picker | `PARTIAL` | `space g t` opens Git panel, not picker | Decide whether panel is acceptable |
| Git | LazyGit integration | Snacks lazygit | `TODO` | Not configured | Likely via tasks later |
| Git | File history via LazyGit | Snacks lazygit log file | `TODO` | Not configured | Could map to native file history later |
| Completion | Blink completion menu behavior | `blink.cmp` | `PARTIAL` | Zed has completions, docs, code actions, snippets; insert keys differ | Decide how much insert-mode remapping to do |
| Completion | Ghost text | `blink.cmp` | `PARTIAL` | Zed has inline completion capabilities, not yet aligned intentionally | Audit settings later |
| LSP | Ruby LSP preferred, Solargraph/RuboCop disabled | `configs/lsp.lua`, Zed settings | `DONE` | Ported in `settings.json` | Keep |
| LSP | ERB with `herb` + `ruby-lsp` | Zed settings / Neovim Ruby workflow intent | `DONE` | Ported in `settings.json` | Keep |
| LSP | Slim custom language server | `configs/lsp.lua` | `TODO` | No Zed parity yet | Future extension/custom language work |
| LSP | Java JDTLS custom setup | `ftplugin/java.lua` | `TODO` | No Zed parity configured | Future language-specific work |
| LSP | Treesitter textobjects and motions | `nvim-treesitter-textobjects` | `PARTIAL` | Zed Vim supports many equivalents, but we are not treating that as full parity yet | Audit key-by-key below |
| LSP | Folding with `ufo.nvim` | `nvim-ufo` | `TODO` | Not configured | Research folding parity in Zed |
| Tests | Neotest nearest/file/all/summary | `neotest.nvim` | `TODO` | Not configured | Future tasks/debug/test work |
| AI | Sidekick integration | `sidekick.nvim` | `TODO` | Not configured | Future AI workflow work |
| Misc | `suda.vim` sudo editing | `suda.vim` | `TODO` | Not represented | Check if needed at all in Zed |
| Misc | Rails-related syntax support for `slim` and `coffee` | `rails.lua`, ftplugins | `TODO` | No dedicated Zed parity yet | Future extension/file type work |

## Full Keybinding Inventory

Rule used here:

- If the exact Neovim key exists in current Zed config and does roughly the same job -> `DONE`.
- If Zed has the capability but on a different key, or with a weaker/different surface -> `PARTIAL`.
- If not implemented yet -> `TODO`.

### Core / global

| Neovim key | Meaning | Source | Status | Current Zed state | Next step |
| --- | --- | --- | --- | --- | --- |
| `<C-h>` | move to left split | `base_mappings` | `PARTIAL` | Zed has `ctrl-w h`; direct `ctrl-h` not mapped | Add direct `ctrl-h` if wanted |
| `<C-j>` | move to lower split | `base_mappings` | `PARTIAL` | Zed has `ctrl-w j`; direct `ctrl-j` not mapped | Add direct `ctrl-j` if wanted |
| `<C-k>` | move to upper split | `base_mappings` | `PARTIAL` | Zed has `ctrl-w k`; direct `ctrl-k` not mapped | Add direct `ctrl-k` if wanted |
| `<C-l>` | move to right split | `base_mappings` | `PARTIAL` | Zed has `ctrl-w l`; direct `ctrl-l` not mapped | Add direct `ctrl-l` if wanted |
| insert `<C-h>` | move left | `base_mappings` | `TODO` | Not mapped | Add only if it feels good in Zed |
| insert `<C-j>` | move down | `base_mappings` | `TODO` | Not mapped | Same |
| insert `<C-k>` | move up | `base_mappings` | `TODO` | Not mapped | Same |
| insert `<C-l>` | move right | `base_mappings` | `TODO` | Not mapped | Same |
| `<leader>qn` | quickfix next | `base_mappings` | `TODO` | No quickfix parity configured | Decide whether diagnostics view should replace this |
| `<leader>qp` | quickfix prev | `base_mappings` | `TODO` | No quickfix parity configured | Same |
| `<leader>qo` | quickfix open | `base_mappings` | `TODO` | No quickfix parity configured | Same |
| `<leader>qc` | quickfix close | `base_mappings` | `TODO` | No quickfix parity configured | Same |
| `<leader>ll` | open Lazy.nvim | `base_mappings` | `TODO` | No Zed equivalent | Probably leave as non-goal |
| `<leader>rnt` | toggle relative numbers | `base_mappings` | `PARTIAL` | Zed has setting-based toggle behavior, but no key bound | Add key if desired |
| `<Esc>` | clear search highlight | `core.lua` | `TODO` | No mapping | Research / accept gap |
| `j` / `k` | wrap-aware movement | `core.lua` | `TODO` | Not configured | Research |
| visual `p` / `P` | paste without clobbering yank | `core.lua` | `TODO` | Not configured | Research |

### Search / find / explorer

| Neovim key | Meaning | Source | Status | Current Zed state | Next step |
| --- | --- | --- | --- | --- | --- |
| `<A-t>` | floating terminal toggle | `snacks` | `TODO` | No equivalent mapping | Future terminal/task workflow |
| `<leader>f<leader>` | picker of pickers | `snacks` | `TODO` | No mapping | Maybe command palette / no direct parity |
| `<leader><leader>` | keymaps picker | `snacks` | `TODO` | No mapping | Maybe command palette / docs / which-key strategy |
| `<leader>fh` | help tags picker | `snacks` | `PARTIAL` | Currently mapped to `outline::Toggle` in Zed | Replace or move if you want true help-oriented behavior |
| `<leader>ff` | find files | `snacks` | `DONE` | `space f f` -> `file_finder::Toggle` | Keep |
| `<leader>fo` | recent files / oldfiles | `snacks` | `TODO` | No mapping | Find Zed recent-files equivalent if any |
| `<leader>fg` | git-tracked files | `snacks` | `TODO` | No mapping | Investigate |
| `<leader>fa` | all files incl. hidden/ignored | `snacks` | `TODO` | No mapping | Investigate finder filters |
| `<leader>fw` | live grep project | `snacks` | `DONE` | `space f w` -> `pane::DeploySearch` | Keep |
| `<leader>fcw` | grep current word | `snacks` | `TODO` | No mapping | Investigate search prefill / send keystrokes |
| `<leader>fcf` | current-file search | `snacks` | `TODO` | No mapping | Investigate buffer search parity |
| `<leader>fb` | buffers picker | `snacks` | `PARTIAL` | `space f b` -> `tab_switcher::Toggle` | Good approximation, but not true buffer picker |
| `<leader>fd` | diagnostics picker | `snacks` | `PARTIAL` | `space q` -> `diagnostics::Deploy` | Panel/multibuffer, not picker |
| `<leader>th` | colorscheme picker | `snacks` | `TODO` | No mapping | Add theme selector later |
| `<leader>td` | TODO picker | `snacks` | `TODO` | No mapping | Future extension / search convention |
| `<leader>gt` | git status picker | `snacks` | `PARTIAL` | `space g t` -> `git_panel::ToggleFocus` | Panel not picker |
| `<leader>gp` | GitHub PR picker | `snacks` | `TODO` | No mapping | Future GitHub integration |
| `<leader>lg` | LazyGit | `snacks` | `TODO` | No mapping | Future task / terminal flow |
| `<leader>lh` | LazyGit current file history | `snacks` | `TODO` | No mapping | Future native file history / task |
| `<leader>e` | explorer reveal | `snacks` | `PARTIAL` | `space e` -> `project_panel::ToggleFocus` | Good but not all explorer affordances mirrored |
| `<leader>E` | explorer with hidden/ignored | `snacks` | `TODO` | No mapping | Investigate project panel hidden settings / action |

### Buffers / tabs

| Neovim key | Meaning | Source | Status | Current Zed state | Next step |
| --- | --- | --- | --- | --- | --- |
| `<leader>bp` | pin current buffer | `bufferline` | `DONE` | `space b p` -> `pane::TogglePinTab` | Keep |
| `<leader>btr` | rename current tab | `bufferline` | `TODO` | No mapping | Investigate if Zed supports named tabs/items |
| `<leader><Tab>` | next tab | `bufferline` | `TODO` | No mapping | Decide if worth modeling separately from items |
| `<leader><S-Tab>` | previous tab | `bufferline` | `TODO` | No mapping | Same |
| `<leader>n<Tab>` | new named tab | `bufferline` | `TODO` | No mapping | Same |
| `<leader>c<Tab>` | close current tab | `bufferline` | `TODO` | No mapping | Same |
| `<Tab>` | next buffer | `bufferline` | `PARTIAL` | `tab` -> `pane::ActivateNextItem` | Item != Bufferline buffer |
| `<S-Tab>` | previous buffer | `bufferline` | `PARTIAL` | `shift-tab` -> `pane::ActivatePreviousItem` | Same |
| `<leader>x` | close current buffer | `bufferline` | `DONE` | `space x` -> `pane::CloseActiveItem` | Keep |

### LSP / code intelligence

| Neovim key | Meaning | Source | Status | Current Zed state | Next step |
| --- | --- | --- | --- | --- | --- |
| `gd` | definition | `lsp_mappings` | `DONE` | Zed Vim native `gd` | Keep |
| `gD` | declaration | `lsp_mappings` | `DONE` | Zed Vim native `gD` | Keep |
| `gr` | references | `lsp_mappings` | `PARTIAL` | Zed native is `gA`, not `gr` | Rebind if you want exact parity |
| `gI` | implementation | `lsp_mappings` | `DONE` | Zed Vim native `gI` | Keep |
| `gtd` | type definition | `lsp_mappings` | `PARTIAL` | Zed native is `gy`, not `gtd` | Rebind if desired |
| `K` | hover | `lsp_mappings` | `PARTIAL` | Zed native is `gh`, not `K` | Rebind if desired |
| `<C-g>` | signature help | `lsp_mappings` | `TODO` | No exact mapping | Research code action / signature surface |
| `<leader>rs` | rename symbol | `lsp_mappings` | `PARTIAL` | Zed native rename is `cd`, not `<leader>rs` | Rebind if desired |
| `<leader>ca` | code action | `lsp_mappings` | `PARTIAL` | Zed native code action is `g.`, not `<leader>ca` | Rebind if desired |
| `<leader>fm` | format | `lsp_mappings` | `TODO` | No explicit mapping | Add if you want exact parity |

### Git

| Neovim key | Meaning | Source | Status | Current Zed state | Next step |
| --- | --- | --- | --- | --- | --- |
| `<leader>gbt` | toggle current line blame | `gitsigns` | `TODO` | No mapping | Research whether toggle action exists |
| `<leader>gp` | previous hunk | `gitsigns on_attach` | `PARTIAL` | Zed native Git Vim uses `[c` / `]c`, not this key | Rebind if exact parity matters |
| `<leader>hn` | next hunk | `gitsigns on_attach` | `PARTIAL` | Zed native Git Vim uses `[c` / `]c`, not this key | Rebind if desired |
| `<leader>hp` | preview hunk | `gitsigns on_attach` | `PARTIAL` | Zed native diff/hunk flow exists, but different UX | Research exact action |

### Commenting / folds / whitespace

| Neovim key | Meaning | Source | Status | Current Zed state | Next step |
| --- | --- | --- | --- | --- | --- |
| `<leader>/` | comment current line | `comment.nvim` | `PARTIAL` | Zed Vim native is `gcc`, not `<leader>/` | Add mapping if exact parity matters |
| visual `<leader>/` | comment selection | `comment.nvim` | `PARTIAL` | Zed Vim native is `gc`, not `<leader>/` | Add mapping if desired |
| `zR` | open all folds | `nvim-ufo` | `TODO` | Not configured | Research fold action support |
| `zM` | close all folds | `nvim-ufo` | `TODO` | Not configured | Same |
| `<leader>zu` | narrow foldcolumn | `nvim-ufo` | `TODO` | No equivalent | Likely non-goal |
| `<leader>zp` | wide foldcolumn | `nvim-ufo` | `TODO` | No equivalent | Likely non-goal |
| `<leader>zh` | hide foldcolumn | `nvim-ufo` | `TODO` | No equivalent | Likely non-goal |
| `<leader>vwst` | visual whitespace toggle | `visual-whitespace.nvim` | `TODO` | Not configured | Future work |

### Tests / sessions / AI

| Neovim key | Meaning | Source | Status | Current Zed state | Next step |
| --- | --- | --- | --- | --- | --- |
| `<leader>tec` | run nearest test | `neotest` | `TODO` | Not configured | Future tasks / testing flow |
| `<leader>tes` | open test summary | `neotest` | `TODO` | Not configured | Same |
| `<leader>tea` | run all tests | `neotest` | `TODO` | Not configured | Same |
| `<leader>tef` | run file tests | `neotest` | `TODO` | Not configured | Same |
| `<leader>ss` | save session | `resession` | `TODO` | Not configured | Major future work |
| `<leader>sl` | load session | `resession` | `TODO` | Not configured | Same |
| `<leader>sd` | delete session | `resession` | `TODO` | Not configured | Same |
| `<leader>sp` | print current session | `resession` | `TODO` | Not configured | Same |
| terminal `<Esc>` | double escape to normal mode | `sidekick` | `TODO` | Not configured | Future AI/terminal work |
| `<leader>as` | next/apply AI edit suggestion | `sidekick` | `TODO` | Not configured | Same |
| `<leader>at` | send this | `sidekick` | `TODO` | Not configured | Same |
| `<leader>af` | send file | `sidekick` | `TODO` | Not configured | Same |
| `<leader>av` | send selection | `sidekick` | `TODO` | Not configured | Same |
| `<leader>ap` | AI prompt selector | `sidekick` | `TODO` | Not configured | Same |
| `<leader>aa` | toggle AI cursor | `sidekick` | `TODO` | Not configured | Same |

### Other plugin / misc mappings

| Neovim key | Meaning | Source | Status | Current Zed state | Next step |
| --- | --- | --- | --- | --- | --- |
| `<leader>000` | disable auto dark mode | `auto-dark-mode` | `TODO` | Not configured | Likely low priority |
| `<leader>apd` | disable autopairs | `autopairs` | `TODO` | Not configured | Low priority |
| `<leader>ape` | enable autopairs | `autopairs` | `TODO` | Not configured | Low priority |
| `<leader>bct` | toggle winbar / breadcrumbs | `barbecue` | `TODO` | Not configured | Need to decide if worth porting |
| `<leader>?` | show local keymaps | `which-key` | `TODO` | Not configured | Need a discoverability solution |
| `<leader>p` | yank history | `yanky` | `TODO` | Not configured | Future work |

## Neovim-Native Features That Zed Already Has But We Are Still Counting As PARTIAL

These are the main "don't call it done too early" items:

- LSP rename: Zed has it on `cd`, but Neovim uses `<leader>rs`.
- LSP code actions: Zed has it on `g.`, but Neovim uses `<leader>ca`.
- LSP references: Zed has it on `gA`, but Neovim uses `gr`.
- Type definition: Zed has it on `gy`, but Neovim uses `gtd`.
- Hover: Zed has it on `gh`, but Neovim uses `K`.
- Comments: Zed has `gcc` / `gc`, but Neovim uses `<leader>/`.
- Git hunk navigation exists in Zed Vim mode, but not on your current Neovim keys.
- Tabs/items exist in Zed, but Bufferline parity is still only approximate.

## Highest-Value Next Steps

If the goal is "make Zed feel like my Neovim as fast as possible", the next best work items are:

1. Add exact LSP parity mappings:
   - `<leader>rs`
   - `<leader>ca`
   - `<leader>fm`
   - `gr`
   - `gtd`
   - `K`
2. Add exact comment parity:
   - `<leader>/` in normal and visual mode
3. Add the missing high-value search bindings:
   - `<leader>fo`
   - `<leader>fcw`
   - `<leader>fcf`
   - `<leader>th`
4. Decide what "buffers/tabs parity" means in Zed:
   - stay with item-based approximation
   - or invest in stronger tab/item remaps
5. Choose the next major workflow to attack:
   - sessions
   - tests
   - lazygit/file history
   - yank history

## Explicit Non-Goals For This Iteration

These are not done and should not be pretended to be done:

- Session restoration parity with `resession.nvim`
- `neotest` parity
- `sidekick.nvim` parity
- `slim_lsp` parity
- Full Bufferline parity
- Full Snacks parity
- Full Noice/Lualine UI parity

