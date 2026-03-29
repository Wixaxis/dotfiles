local home = os.getenv("HOME")
require("bunny"):setup({
  hops = {
    { tag = "home",       path = home,                 key = "h" },
    { tag = "config",     path = home.."/.config",     key = "c" },
    { tag = "dotfiles",   path = home.."/dotfiles",    key = "." },
    { tag = "tmp-home",   path = home.."/tmp",         key = "t" },
    { tag = "tmp",        path = "/tmp",               key = "T" },
    { tag = "downloads",  path = home.."/Pobrane",     key = "d" },
    { tag = "university", path = home.."/studia",      key = "u" },
    { tag = "BigData",    path = "/mnt/BigData",       key = "B" },
    { tag = "FastData",   path = "/mnt/FastData",      key = "F" },
    { tag = "media",      path = "/run/media/wixaxis", key = "M" },
  },
  -- notify = true, -- notify after hopping, default is false
  -- fuzzy_cmd = "sk", -- fuzzy searching command, default is fzf
})


require("full-border"):setup()
