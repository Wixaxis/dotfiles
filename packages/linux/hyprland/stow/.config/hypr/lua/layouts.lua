-- Layout configuration

hl.config({
    master = {
        new_status = "slave",
        orientation = "left",
        mfact = 0.7,
        allow_small_split = true,
    },

    dwindle = {
        force_split = 2,
        split_width_multiplier = 0.5,
    },

    scrolling = {
        column_width = 0.49,
        fullscreen_on_one_column = true,
        focus_fit_method = 1,
        follow_focus = true,
        follow_min_visible = 0.4,
        direction = "right",
    },
})

-- Device-specific scrolling override based on hostname
local hostname = os.getenv("HOSTNAME") or ""

if hostname == "wixaxis-minibook" then
    -- Wider windows for minibook (90% width)
    hl.config({ scrolling = { column_width = 0.9 } })
end
