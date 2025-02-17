let carapace_completer = { |spans| carapace $spans.0 nushell ...$spans | from json }

$env.config = ($env.config | upsert completions {
    external: {
        enable: true
        completer: $carapace_completer
    }
})
