# Wob Configuration

Wob (Wayland OSD Bar) is a lightweight overlay bar for displaying volume, brightness, and other progress indicators.

## Installation

```bash
sudo pacman -S wob
```

## Configuration

The config file is at `~/.config/wob/config.ini` and uses Nord theme colors.

## Usage

After installing wob, the volume OSD script (`scripts/scripts/volume-osd.sh`) will automatically use wob instead of notifications.

## Features

- Clean, minimal bar display
- Nord-themed colors
- Appears at top-right corner
- Auto-hides after 1 second
- Shows volume percentage or "MUTED" status
