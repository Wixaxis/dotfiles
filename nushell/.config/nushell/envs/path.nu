# Path for existing tools
$env.PATH = ($env.PATH 
    | split row (char esep) 
    | append '/opt/homebrew/bin' 
    | append $"($env.HOME)/.rbenv/shims"
    | append '/opt/homebrew/opt/trash-cli/bin')
