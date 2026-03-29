# Path for existing tools
$env.PATH = ($env.PATH 
    | split row (char esep) 
    | append $"($env.HOME)/.local/bin")
    # mise manages PATH automatically, no manual addition needed
