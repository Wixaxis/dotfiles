# Ferdium

Installs the stable Ferdium macOS app from Homebrew's main cask repository.

## Local data

Ferdium stores its macOS profile under:

```text
~/Library/Application Support/Ferdium
```

Do not link or commit that whole directory. It combines reusable application
state with Chromium cookies, local/session storage, caches, service partitions,
and other authenticated browser data.

In anonymous mode, service definitions, workspaces, and much of the app setup
live in `server.sqlite`. The reviewed `config/services.ferdium-data` export
contains the portable service layout without web-service login sessions. Import
it once from Ferdium's local account-data transfer screen on a new machine.

The package links the sanitized `config/settings.json` and
`config/shortcuts.json` preferences directly. Never commit `config/proxy.json`,
the live SQLite database, browser storage, service partitions, or credentials.

The GPChaT service uses a custom icon on the original machine. Ferdium exports
only a machine-local icon reference, not the image, so the portable export uses
the normal ChatGPT recipe icon instead.
