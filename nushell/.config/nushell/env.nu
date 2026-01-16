$env.NU_CUSTOM_CONFIG_PATH = $"($env.HOME)/.config/nushell"
$env.TERMINAL = 'ghostty'
source ./envs/path.nu
source ./envs/editor.nu
source ./envs/anthropic_claude.nu

# XDG Base Directory setup (Linux only)
# macOS uses ~/Library paths, so XDG is only configured on Linux
if ($nu.os-info.name == "linux") {
    source ./envs/xdg.nu
}

# AI-related env files (optional - comment out if not needed)
# These provide API keys and configurations for various AI services
source ./envs/gemini.nu
source ./envs/open_ai.nu
source ./envs/openrouter.nu
source ./envs/tavily.nu

if ($env.MISE_SET_ENV? | is-empty) {
	source ./envs/mise.nu
	$env.MISE_SET_ENV = "1"
}
