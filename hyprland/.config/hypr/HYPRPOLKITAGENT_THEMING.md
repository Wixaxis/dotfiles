# hyprpolkitagent Theming Reference

This document explains how to customize and theme `hyprpolkitagent`, the polkit authentication agent for Hyprland.

## Overview

`hyprpolkitagent` is written in **Qt/QML** and uses Qt's theming system. The UI is defined in a QML file that uses `SystemPalette` for colors, which automatically respects your Qt theme settings.

## Theming Methods

### Method 1: Qt Theme Configuration (Recommended)

Since `hyprpolkitagent` uses Qt's `SystemPalette`, it automatically respects your Qt theme configuration.

**Current Setup:**
- `QT_QPA_PLATFORMTHEME=qt6ct` is already set in `variables.conf`
- This means `hyprpolkitagent` will use your qt6ct theme settings

**To Customize:**
1. Open qt6ct: `qt6ct`
2. Configure your theme, colors, and style
3. Changes will apply to `hyprpolkitagent` automatically

**Note:** The agent uses `SystemPalette` which pulls colors from your Qt theme, so configuring qt6ct should make it match your system theme.

### Method 2: Environment Variables

You can override Qt theme settings via environment variables:

```bash
# In variables.conf or autostart
env = QT_QPA_PLATFORMTHEME, qt6ct
env = QT_STYLE_OVERRIDE, kvantum
```

**Available Qt Styles:**
- `qt6ct` - Qt6 Configuration Tool (recommended)
- `kvantum` - Kvantum theme engine
- `adwaita` - GNOME Adwaita theme
- `gtk2` - GTK2 theme
- `gtk3` - GTK3 theme

### Method 3: Custom QML Override (Advanced)

The default QML file is located at `qml/main.qml` in the source repository. To customize it:

1. **Find the installed QML location:**
   ```bash
   # Check package files
   pacman -Ql hyprpolkitagent | grep qml
   # Or check common locations
   find /usr -name "main.qml" -path "*polkit*"
   ```

2. **Create a custom QML file:**
   - Copy the default `main.qml` from the repository
   - Modify colors, fonts, spacing, etc.
   - Place it in a custom location

3. **Override the QML path:**
   - This may require recompiling or using a wrapper script
   - Check if there's a config option or environment variable

**Note:** Custom QML override is not officially documented and may require source modification or recompilation.

## Current QML Structure

The default `main.qml` uses:

- **SystemPalette** - Automatically uses system colors
- **FontMetrics** - Responsive sizing based on font
- **Colors:**
  - `system.windowText` - Text color
  - `system.window` - Background color
  - `Qt.darker(system.windowText, 0.8)` - Dimmed text
  - `"red"` - Error messages

## Quick Fixes

### Make it Match Your Theme

1. **Ensure qt6ct is configured:**
   ```bash
   qt6ct
   ```
   - Select your preferred theme (Nord, Adwaita, etc.)
   - Configure colors to match your system

2. **Verify environment variables:**
   ```bash
   # Check current settings
   echo $QT_QPA_PLATFORMTHEME
   ```

3. **Restart hyprpolkitagent:**
   ```bash
   systemctl --user restart hyprpolkitagent
   ```

### Common Issues

**Problem:** Agent still looks ugly/default
- **Solution:** Make sure `QT_QPA_PLATFORMTHEME=qt6ct` is set and qt6ct is configured

**Problem:** Colors don't match system
- **Solution:** Configure qt6ct with a theme that matches your GTK/Kvantum theme

**Problem:** Fonts look wrong
- **Solution:** Set font in qt6ct or via `QT_FONT_FAMILY` environment variable

## References

- **Source Repository:** https://github.com/hyprwm/hyprpolkitagent
- **Default QML:** https://raw.githubusercontent.com/hyprwm/hyprpolkitagent/main/qml/main.qml
- **Hyprland Wiki:** https://wiki.hyprland.org/Hypr-Ecosystem/hyprpolkitagent/
- **Qt6 Configuration Tool:** https://github.com/trialanderror/qt6ct

## Implementation Notes

Since `hyprpolkitagent` uses Qt's `SystemPalette`, the most reliable way to theme it is through Qt theme configuration (qt6ct). The agent will automatically pick up colors from your configured Qt theme.

For a fully custom look, you would need to:
1. Modify the QML source
2. Recompile the package, OR
3. Use a wrapper script that overrides the QML path (if supported)

The easiest approach is to configure qt6ct with a theme that matches your system aesthetic.

---

**Last Updated:** Based on hyprpolkitagent source code analysis
**QML File:** `qml/main.qml` in repository
**Theming System:** Qt SystemPalette (respects qt6ct configuration)
