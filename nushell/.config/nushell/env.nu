$env.NU_CUSTOM_CONFIG_PATH = $"($env.HOME)/.config/nushell"
$env.TERMINAL = 'ghostty'
source ./envs/path.nu
source ./envs/editor.nu
source ./envs/anthropic_claude.nu
source ./envs/xdg.nu


if ($env.MISE_SET_ENV? | is-empty) {
	source ./envs/mise.nu
	$env.MISE_SET_ENV = "1"
}
