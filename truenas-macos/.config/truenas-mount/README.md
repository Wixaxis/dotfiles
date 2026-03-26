# TrueNAS SMB Automount (macOS)

This package contains only safe-to-track pieces:

- LaunchAgent plist in `~/Library/LaunchAgents/`
- Example env template in `~/.config/truenas-mount/`

Your real credentials file is local-only and should not be committed:

- `~/.config/truenas-mount/truenas-smb.env`

## Setup

1. Stow package:
   - `stow -t ~ truenas-macos`
2. Copy template:
   - `cp ~/.config/truenas-mount/truenas-smb.env.example ~/.config/truenas-mount/truenas-smb.env`
3. Edit values in `truenas-smb.env`.
4. Lock permissions:
   - `chmod 600 ~/.config/truenas-mount/truenas-smb.env`
5. Ensure script is available:
   - `~/scripts/mount_truenas_smb.sh`
6. Load agent:
   - `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.wixaxis.mount-truenas.plist`
   - `launchctl kickstart -k gui/$(id -u)/com.wixaxis.mount-truenas`

## Useful Checks

- `launchctl print gui/$(id -u)/com.wixaxis.mount-truenas`
- `mount | rg "/Users/wixaxis/mnt/truenas"`
- `tail -n 100 /tmp/com.wixaxis.mount-truenas.out.log`
- `tail -n 100 /tmp/com.wixaxis.mount-truenas.err.log`
