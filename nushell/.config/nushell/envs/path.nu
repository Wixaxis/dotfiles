# Path for existing tools
$env.PATH = ($env.PATH 
    | split row (char esep) 
    | append $"($env.HOME)/.local/bin"
    | append $"($env.HOME)/.rbenv/shims"
    | append $"($env.HOME)/.local/share/gem/ruby/3.3.0/bin")
