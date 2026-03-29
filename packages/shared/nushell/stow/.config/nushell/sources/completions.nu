let carapace_completer = { |spans| carapace $spans.0 nushell ...$spans | from json }

# Ensure config table exists
if ($env.config? | is-empty) {
    $env.config = {}
}

$env.config = ($env.config | upsert completions {
    external: {
        enable: true
        completer: $carapace_completer
    }
})
