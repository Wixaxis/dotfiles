-- Input configuration

hl.config({
    input = {
        kb_layout = "pl",
        kb_variant = "",
        kb_model = "pc105+inet",
        kb_options = "terminate:ctrl_alt_bksp",
        kb_rules = "",
        repeat_rate = 25,
        repeat_delay = 600,
        sensitivity = -0.6,
        follow_mouse = 1,

        touchpad = {
            natural_scroll = true,
            disable_while_typing = false,
        },

        touchdevice = {
            output = "DSI-1",
            transform = 3,
        },
    },
})

-- Device-specific overrides based on hostname
local hostname = os.getenv("HOSTNAME") or ""

if hostname == "wixaxis-minibook" then
    -- Faster cursor speed for minibook
    hl.config({ input = { sensitivity = 0.0 } })
end
