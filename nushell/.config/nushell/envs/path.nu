# Path for existing tools
$env.PATH = ([
    '/opt/homebrew/bin'
    '/opt/homebrew/sbin'
    '/opt/homebrew/opt/trash-cli/bin'
    $"($env.HOME)/.cache/.bun/bin"
    $"($env.HOME)/.local/bin"
    $"($env.HOME)/.local/share/bob/nvim-bin"
] | append ($env.PATH | split row (char esep)))
