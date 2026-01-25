# Device-Specific Configuration in Hyprland

## Overview

This repository uses a simple script-based approach for device-specific configuration overrides. The script applies defaults first, then device-specific settings based on hostname detection.

## Current Implementation

**Script:** `scripts/scripts/apply-device-config.sh`

**In `hyprland.conf`:**
```conf
input {
    # Default sensitivity (device-specific overrides applied via apply-device-config.sh)
    sensitivity = -0.6
}
```

**In `autostart.conf`:**
```conf
exec-once = bash /home/wixaxis/scripts/scripts/apply-device-config.sh
```

**How it works:**
1. Script runs on Hyprland startup via `exec-once`
2. Sets default values first (applies to all devices)
3. Detects hostname using `uname -n`
4. Applies device-specific overrides using `hyprctl keyword`
5. Works regardless of how Hyprland is started (shell, display manager, etc.)

**Advantages:**
- Simple and maintainable
- Works on every boot, regardless of startup method
- Easy to add new devices
- All device-specific configs in one place

## Adding Device-Specific Settings

### Step 1: Determine your hostname
```bash
uname -n
# Example output: wixaxis-minibook
```

### Step 2: Edit the device config script
Open `scripts/scripts/apply-device-config.sh` and add your device-specific settings:

```bash
case "$HOSTNAME" in
    wixaxis-minibook)
        # Faster cursor speed for minibook
        hyprctl keyword input:sensitivity 0.0
        ;;
    your-device-name)
        # Your device-specific settings here
        hyprctl keyword input:sensitivity 0.5
        hyprctl keyword general:gaps_in 8
        ;;
esac
```

### Step 3: Test the script
```bash
bash /home/wixaxis/scripts/scripts/apply-device-config.sh
hyprctl getoption input:sensitivity  # Verify it worked
```

### Step 4: Restart Hyprland
The script runs automatically on startup. For immediate effect:
```bash
# Restart Hyprland, or manually run:
bash /home/wixaxis/scripts/scripts/apply-device-config.sh
```

**Note:** `hyprctl reload` won't re-run `exec-once` commands. You need to restart Hyprland or manually run the script.

## Finding Your Hostname

```bash
uname -n
# or
cat /etc/hostname
```

## Alternative Approaches

### hyprlang Conditionals

Hyprland 0.6.4+ supports conditional blocks, but they require environment variables to be set **before** Hyprland parses the config. This makes them less practical for device-specific configs unless you use wrapper scripts or systemd overrides.

See [Hyprlang Documentation](https://wiki.hypr.land/Hypr-Ecosystem/hyprlang/) for details.

### Machine-Specific Config Files

Create a machine-specific config file that's gitignored:

1. Create `~/.config/hypr/machine-$(hostname).conf`
2. Add `machine-*.conf` to `.gitignore`
3. Source it in `hyprland.conf`:
   ```conf
   source = ~/.config/hypr/machine-$(hostname).conf
   ```

**Pros:**
- Clean separation of machine-specific settings
- Easy to manage multiple machine-specific options

**Cons:**
- Hyprland will error if the file doesn't exist (must create empty file on other machines)

## References

- [Hyprlang Documentation](https://wiki.hypr.land/Hypr-Ecosystem/hyprlang/)
- [Hyprland Configuring Docs](https://wiki.hypr.land/Configuring/Configuring-Hyprland/)
- [Hyprland Variables Docs](https://wiki.hypr.land/Configuring/Variables/)
