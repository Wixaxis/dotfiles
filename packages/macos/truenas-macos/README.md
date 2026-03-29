# TrueNAS SMB Automount (macOS)

This package contains only safe-to-track pieces:

- LaunchAgent plist in `~/Library/LaunchAgents/`
- Example env template in `~/.config/truenas-mount/`

Your real credentials file is local-only and should not be committed:

- `~/.config/truenas-mount/truenas-smb.env`

Package-specific behavior:

- `post_link` can copy the example env file into place if the real env file does not exist yet
- `post_link` can optionally bootstrap the LaunchAgent on macOS
- `is_stowed.sh` verifies the tracked links and the presence of the local env file

## Setup

1. Apply the package:
   - `./setup.sh --package truenas-macos`
2. If `post_link` did not already create `~/.config/truenas-mount/truenas-smb.env`, create it manually:
   - `cp ~/.config/truenas-mount/truenas-smb.env.example ~/.config/truenas-mount/truenas-smb.env`
3. Edit values in `truenas-smb.env`.
4. Lock permissions:
   - `chmod 600 ~/.config/truenas-mount/truenas-smb.env`
5. Ensure script is available:
   - `~/scripts/mount_truenas_smb.sh`
6. Load agent:
   - `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.wixaxis.mount-truenas.plist`
   - `launchctl kickstart -k gui/$(id -u)/com.wixaxis.mount-truenas`

The mount script is provided by the shared `scripts` package, so the normal root setup flow should apply that package too.

## Useful Checks

- `launchctl print gui/$(id -u)/com.wixaxis.mount-truenas`
- `mount | rg "/Users/wixaxis/mnt/truenas"`
- `tail -n 100 /tmp/com.wixaxis.mount-truenas.out.log`
- `tail -n 100 /tmp/com.wixaxis.mount-truenas.err.log`
