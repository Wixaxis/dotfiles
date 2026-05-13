-- General, decoration, cursor, and misc settings

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 5,
        border_size = 1,
        col = {
            active_border = "rgb(bf616a)",
            inactive_border = "rgb(5e81ac)",
        },
        layout = "scrolling",
        resize_on_border = true,
        hover_icon_on_border = false,
    },

    cursor = {
        no_hardware_cursors = true,
    },

    decoration = {
        rounding = 5,
        active_opacity = 1.0,
        inactive_opacity = 0.99,
        fullscreen_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.005,

        blur = {
            enabled = true,
            size = 8,
            passes = 1,
            xray = true,
            noise = 0.1,
        },
    },

    misc = {
        focus_on_activate = false,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})
