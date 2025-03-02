export def ansi_compile [] { $in | ruby $"($env.NU_CUSTOM_CONFIG_PATH)/scripts/ruby/ansi_compile.rb" }
