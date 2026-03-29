# Starship Custom Module Reference

## Research Date
2025-01-16

## Problem
Trying to add a shell indicator `(nu)` or `(zsh)` to Starship prompt using custom modules, but encountering issues with format syntax.

## Findings from `starship print-config`

The current configuration shows:
```toml
[custom.shell]
format = "[$output]($style) "
symbol = ""
command = 'test -n "$STARSHIP_SHELL" && echo "($STARSHIP_SHELL)" || echo "(sh)"'
when = false  # <-- THIS IS THE PROBLEM!
require_repo = false
shell = ["sh", "-c"]
description = "<custom config>"
style = "bold dimmed"
disabled = false
```

## Key Discovery
- **`when = false`** disables the module, causing it to not execute
- The format `[$output]($style)` is correct
- The command syntax is correct
- Need to either remove `when` or set it to `true` or a valid condition

## Correct Custom Module Syntax

```toml
[custom.module_name]
command = 'your command here'
format = '[$output]($style)'
style = 'bold dimmed'
shell = ['sh', '-c']
# when = 'condition'  # Optional: only show when condition is true
# disabled = false    # Optional: set to true to disable
```

## Format String Variables
- `$output` - The output from the command
- `$style` - The style defined in the module config
- `$symbol` - Optional symbol (if defined)

## Solution
Remove the `when = false` line or set it to a valid condition like `when = 'test -n "$STARSHIP_SHELL"'`

## Current Issue
Even after removing `when` from config, `starship print-config` still shows `when = false`. This suggests:
1. Starship may set `when = false` by default if no condition is provided
2. Need to explicitly set `when = true` or provide a valid condition
3. The command works when tested manually, so the issue is with the `when` condition

## Test Results
- Command works: `STARSHIP_SHELL=zsh sh -c 'test -n "$STARSHIP_SHELL" && echo "($STARSHIP_SHELL)" || echo "(sh)"'` outputs `(zsh)`
- Command works: `STARSHIP_SHELL=nu sh -c 'test -n "$STARSHIP_SHELL" && echo "($STARSHIP_SHELL)" || echo "(sh)"'` outputs `(nu)`
- Config shows: `when = false` in print-config output

## Next Steps
1. ✅ Try setting `when = true` explicitly (testing now)
2. Try setting `when = 'test -n "$STARSHIP_SHELL"'` 
3. Check if there's a different way to always show custom modules
4. Look for examples of always-on custom modules

## Testing Results
- `starship module custom.shell` returns nothing (module not running)
- Tried `when = true` (boolean) - didn't work
- Tried `when = 'true'` (string command) - still not working
- The `when` condition might need to be a shell command that returns 0, not a boolean
- **Issue**: Even with `when = 'true'`, the module still shows `when = false` in `print-config`

## Hypothesis
The `when` field might be evaluated at config parse time, not runtime. If the condition evaluates to false during parsing, it might be set to false permanently. Need to find a way to make it always true, or use a different approach.

## Alternative Approaches to Consider
1. Use a different module type (not custom)
2. Modify the format string directly to include shell name
3. Use environment variable substitution in format
4. ✅ **Found**: There IS a built-in `shell` module in Starship! Check if we can customize it
5. Use the built-in `shell` module instead of custom module

## ✅ SOLUTION FOUND: Built-in Shell Module!

**The built-in `shell` module is the answer!**

From `starship print-config`:
```toml
[shell]
format = "[$indicator]($style) "
zsh_indicator = "zsh"
nu_indicator = "nu"
```

**We can customize the indicators to show "(zsh)" and "(nu)"!**

This is much simpler than custom modules. Just need to:
1. Enable the `shell` module (it might be disabled by default)
2. Customize `zsh_indicator = "(zsh)"` and `nu_indicator = "(nu)"`
3. Add `$shell` to the format string instead of `$custom.shell`

## Implementation Status
- ✅ Removed `custom.shell` module
- ✅ Added built-in `shell` module configuration
- ✅ Set `disabled = false` to enable shell module
- ✅ Updated format to use `$shell` instead of `$custom.shell`
- ✅ Customized indicators: `zsh_indicator = 'zsh'` and `nu_indicator = 'nu'`
- ✅ Cleared Starship cache
- ⚠️ User still reporting `.shell ~` display issue

## Current Issue
User is still seeing `.shell ~` which suggests:
1. The shell module might not be detecting the shell correctly
2. There might be a `when` condition preventing it from showing
3. The format might need adjustment
4. May need to restart shell completely (not just source config)

## Next Steps
- Check if shell module has any `when` conditions
- Verify shell detection is working
- Test in a completely new shell session

---

## ✅ FINAL WORKING SOLUTION

**Date Fixed:** 2025-01-16

### The Problem
We were trying to use `$env_var.STARSHIP_SHELL` in the format string, but Starship was displaying `.STARSHIP_SHELL` literally instead of resolving the module output.

### The Solution
Use the **built-in `$shell` module** and put formatting (like parentheses) directly in the format string, not in environment variables.

### Key Insights

1. **Built-in `shell` module**: Starship has a built-in `shell` module that automatically detects the current shell. You reference it in the format string as `$shell`.

2. **Format string syntax**: The format string can contain literal text alongside module references. Parentheses are just literal characters in the format string.

3. **Module configuration**: The `shell` module needs to be enabled with `disabled = false` and can be customized with per-shell indicators.

### Working Configuration

**`starship.toml`:**
```toml
format = """
($shell)\
$directory\n$right_prompt"""

[shell]
unknown_indicator = '???'
format = "[$indicator]($style) "
disabled = false
```

**Key points:**
- `($shell)` in the format string: The parentheses are literal text, `$shell` is the module reference
- The backslash `\` at the end of the first line prevents a newline in the output
- The `shell` module's own `format` controls how the indicator is styled
- The `shell` module automatically detects the shell (zsh, nu, bash, etc.) and uses the appropriate indicator

### Why This Works vs. Previous Attempts

1. **`$env_var.STARSHIP_SHELL` didn't work**: The dot notation in the top-level format string was being interpreted literally, not as a module reference. Starship's format parser may have issues with nested module references in certain contexts.

2. **`$shell` works**: The `shell` module is a first-class built-in module that Starship knows how to resolve in format strings. It's designed for this exact use case.

3. **Formatting in format string**: Instead of trying to include parentheses in environment variables or module outputs, we put them directly in the format string where they're needed. This is simpler and more reliable.

### What We Learned

- **Use built-in modules when available**: Starship has many built-in modules for common use cases. Always check if a built-in module exists before creating custom solutions.

- **Format strings can contain literals**: You can mix module references (`$shell`, `$directory`) with literal text (`(`, `)`, spaces, newlines) in format strings.

- **Module reference syntax**: In the top-level `format` string, you reference modules by name with `$module_name`. The module's own `format` configuration controls its internal styling.

- **Shell detection is automatic**: The `shell` module automatically detects the current shell based on the shell Starship is running in. No need to set environment variables.

### Cleanup

The `STARSHIP_SHELL` environment variable is no longer needed in shell initialization files, though leaving it set doesn't cause issues (it's just unused).
