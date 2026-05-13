-- Monitor configuration

-- Primary monitor (auto-detect)
hl.monitor({
    output = "",
    mode = "highres",
    position = "auto",
    scale = 1,
})

-- External monitor
hl.monitor({
    output = "HDMI-A-2",
    mode = "3440x1440@100",
    position = "auto",
    scale = 1,
})

-- Tablet/touchscreen (rotated)
hl.monitor({
    output = "DSI-1",
    mode = "1200x1920@50",
    position = "0x0",
    scale = 1,
    transform = 3,
})
