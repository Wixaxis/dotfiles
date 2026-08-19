# Raycast v2 beta

This package manages configuration for the separate Raycast v2 beta app.

Raycast v2 beta is currently distributed directly by Raycast and installs as
`/Applications/Raycast Beta.app` with bundle identifier
`com.raycast-x.macos`. It is not the Homebrew `raycast` cask, which installs
Raycast v1. For that reason, installation is intentionally manual during the
beta while `is_stowed.sh` verifies the actual v2 app.

Download the beta from:

```text
https://www.raycast.com/new
```

## Local AI provider credentials

`stow/.config/raycast/ai/providers.yaml` is deliberately ignored and is not a
manifest-managed link because it contains an OpenCode Go API credential. The
existing local symlink remains usable on this machine, but the credential must
be configured separately on a new machine. Never commit this file.
