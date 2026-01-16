# Initialize config table if it doesn't exist
if ($env.config? | is-empty) {
    $env.config = {}
}

$env.config = ($env.config | upsert show_banner false)
