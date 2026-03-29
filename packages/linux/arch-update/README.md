# Arch Linux Update Configuration

This package stores the Arch maintenance files tracked in the repo.

Tracked payload:

- `~/.config/arch-update/arch-update.conf`
- `~/.config/pacman/hooks/pacnew.hook`
- `~/.config/pacman/hooks.bin/pacnew-handler.sh`
- `~/.config/systemd/user/reflector-update.service`
- `~/.config/systemd/user/reflector-update.timer`

## What The Package Does

Applying the package links the tracked files into your home directory using the metadata-driven setup flow:

```bash
./setup.sh --package arch-update
```

The package itself does not currently install system-wide pacman hooks under `/etc/pacman.d/hooks/` and does not automatically enable the reflector timer. Those steps remain explicit and manual.

## Pacman Hooks

The repo tracks the pacnew hook source files under `~/.config/pacman/` so they stay versioned with the rest of the package.

If you want them active system-wide, copy them into `/etc/pacman.d/hooks/`:

```bash
sudo mkdir -p /etc/pacman.d/hooks/bin
sudo cp ~/.config/pacman/hooks/pacnew.hook /etc/pacman.d/hooks/
sudo cp ~/.config/pacman/hooks.bin/pacnew-handler.sh /etc/pacman.d/hooks/bin/
sudo chmod +x /etc/pacman.d/hooks/bin/pacnew-handler.sh
```

## Reflector Timer

The package also tracks user systemd units for reflector updates.

Enable them manually if you want them active:

```bash
systemctl --user daemon-reload
systemctl --user enable --now reflector-update.timer
```
