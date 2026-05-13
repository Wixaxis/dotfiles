-- Window rules

-- General rules
hl.window_rule({ match = { title = "^(Neovide)$" }, tile = true })
hl.window_rule({ match = { title = "^(Settings)$" }, float = true })

-- Flameshot multi-display fix
hl.window_rule({ match = { class = "^(flameshot)$" }, float = true })
hl.window_rule({ match = { class = "^(flameshot)$" }, pin = true })
hl.window_rule({ match = { class = "^(flameshot)$" }, rounding = 0 })
hl.window_rule({ match = { class = "^(flameshot)$" }, border_size = 0 })
hl.window_rule({ match = { class = "^(flameshot)$" }, fullscreen_state = "0 0" })
hl.window_rule({ match = { class = "^(flameshot)$" }, move = {0, 0} })
hl.window_rule({ match = { class = "^(flameshot)$" }, animation = "fade" })

-- Bitwarden extension popups in Zen Browser
hl.window_rule({
    match = { title = "^(Extension: \\(Bitwarden Password Manager\\) - Bitwarden - Zen Browser)$" },
    float = true,
})
hl.window_rule({
    match = { title = "^(Extension:.*Bitwarden.*)$", class = "^(zen-alpha)$" },
    float = true,
})

-- Steam empty-title windows
hl.window_rule({ match = { title = "^()$", class = "^(steam)$" }, stay_focused = true })
hl.window_rule({ match = { title = "^()$", class = "^(steam)$" }, min_size = {1, 1} })

-- Picture-in-Picture
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, pin = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, size = {320, 180} })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, move = {"100%-325", "100%-185"} })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, no_initial_focus = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, tag = "-hyprbars:nobar" })
