# Arch Linux Update Configuration

This directory contains configuration for Arch Linux system maintenance.

## Contents

### arch-update.conf
Configuration for the `arch-update` tool (if installed).

### Pacman Hooks (`pacman/hooks/`)

**pacnew.hook** - Automatically handles .pacnew files after pacman transactions
- Backs up existing configs before replacing
- Removes identical .pacnew files
- Logs all actions to system journal
- Sends desktop notification when complete

**hooks.bin/pacnew-handler.sh** - The handler script that processes .pacnew files

These hooks need to be installed system-wide:
```bash
sudo mkdir -p /etc/pacman.d/hooks/bin
sudo cp ~/.config/pacman/hooks/pacnew.hook /etc/pacman.d/hooks/
sudo cp ~/.config/pacman/hooks.bin/pacnew-handler.sh /etc/pacman.d/hooks/bin/
sudo chmod +x /etc/pacman.d/hooks/bin/pacnew-handler.sh
```

Or simply run `./setup.sh` which will offer to install them automatically.

### Systemd User Services (`systemd/user/`)

**reflector-update.service** - Updates pacman mirror list using reflector
**reflector-update.timer** - Runs the mirror update weekly

These run as user services (don't require root):
```bash
systemctl --user daemon-reload
systemctl --user enable reflector-update.timer
systemctl --user start reflector-update.timer
```

Or simply run `./setup.sh` which will set them up automatically.

## Automatic Setup

Run the main setup script to configure everything:
```bash
./setup.sh
```

This will:
- Detect Arch Linux
- Offer to install pacman hooks
- Setup the reflector timer
- Check if mirror list needs updating
