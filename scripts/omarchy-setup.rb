#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "optparse"
require "pathname"

class OmarchySetup
  THEME = "Nord"
  FONT = "Adwaita Mono"
  TERMINAL = "ghostty"
  KEY_REPEAT_RATE = 20
  KEY_REPEAT_DELAY = 500
  WINDOW_LAYOUT = "scrolling"
  WORKSPACE_ANIMATION_SPEED = 3

  def initialize(argv)
    @dry_run = false
    @check = false
    @list = false
    @changed = false
    @hyprland_changed = false
    @menu_changed = false
    @backed_up = {}
    @home = Pathname(ENV.fetch("DOTFILES_HOME", ENV.fetch("HOME"))).expand_path
    parse!(argv)
  end

  def run
    if @list
      puts "bar, clock, menu aliases, monitor scale, keyboard repeat, keybindings, window layout, workspace animation, theme, font, terminal, OpenCode Desktop, OpenCode 2"
      return
    end

    heading("Omarchy Setup")
    ensure_bar
    ensure_menu_aliases
    ensure_monitor_scale
    ensure_keyboard_repeat
    ensure_keybindings
    ensure_window_layout
    ensure_workspace_animation
    ensure_setting("Theme", current: capture("omarchy", "theme", "current"), desired: THEME) do
      command("omarchy", "theme", "set", THEME)
    end
    ensure_setting("Font", current: capture("omarchy", "font", "current"), desired: FONT) do
      command("omarchy", "font", "set", FONT)
    end
    ensure_terminal
    ensure_opencode
    command("omarchy", "menu", "refresh") if @menu_changed && !@dry_run && !@check
    validate_hyprland if @hyprland_changed && !@dry_run && !@check

    if @check && @changed
      status("Setup differs", ok: false)
      exit 1
    end

    status(@changed ? (@dry_run ? "Changes needed" : "Setup complete") : "Already configured", ok: true)
  end

  private

  def parse!(argv)
    OptionParser.new do |options|
      options.on("--dry-run") { @dry_run = true }
      options.on("--check") { @check = true }
      options.on("--list") { @list = true }
      options.on("--yes") {}
      options.on("--no-install") {}
    end.parse!(argv)
  end

  def ensure_bar
    path = @home.join(".config/omarchy/shell.json")
    config = JSON.parse(path.read)
    clock = config.dig("bar", "layout")&.values&.flatten&.find { |item| item["id"] == "omarchy.clock" }

    ensure_setting("Bar position", current: config.dig("bar", "position"), desired: "left") do
      backup(path)
      command("omarchy", "bar", "position", "left")
    end
    ensure_setting("Clock birth year", current: clock&.fetch("birthYear", nil), desired: 1999) do
      backup(path)
      command("omarchy", "bar", "set", "omarchy.clock", "birthYear", "1999", "--json")
    end
    ensure_setting("Clock life expectancy", current: clock&.fetch("lifeExpectancy", nil), desired: 90) do
      backup(path)
      command("omarchy", "bar", "set", "omarchy.clock", "lifeExpectancy", "90", "--json")
    end
  rescue Errno::ENOENT, JSON::ParserError => e
    abort "Cannot read #{path}: #{e.message}"
  end

  def ensure_monitor_scale
    path = @home.join(".config/hypr/monitors.lua")
    content = path.read
    abort "Cannot find Omarchy scale settings in #{path}" unless
      content.match?(/^local omarchy_gdk_scale = /) && content.match?(/^local omarchy_monitor_scale = /)

    desired = content
      .sub(/local omarchy_gdk_scale = .*/, "local omarchy_gdk_scale = 1")
      .sub(/local omarchy_monitor_scale = .*/, "local omarchy_monitor_scale = 1")

    if content == desired
      status("Monitor scale: 1", ok: true)
      return
    end

    @changed = true
    @hyprland_changed = true
    status("Monitor scale → 1", ok: false)
    return if @dry_run || @check

    backup(path)
    path.write(desired)
  rescue Errno::ENOENT => e
    abort "Cannot read #{path}: #{e.message}"
  end

  def ensure_menu_aliases
    path = @home.join(".config/omarchy/extensions/omarchy-menu.jsonc")
    content = path.read
    start_marker = "  // dotfiles: menu aliases start"
    end_marker = "  // dotfiles: menu aliases end"
    block = <<~JSONC.chomp.lines.map { |line| "  #{line}" }.join
      // dotfiles: menu aliases start
      "system.suspend": {"icon":"󰒲","label":"Suspend","aliases":["sleep"],"when":"! omarchy-toggle-enabled suspend-off","action":"systemctl suspend"},
      // dotfiles: menu aliases end
    JSONC
    pattern = /^#{Regexp.escape(start_marker)}$.*?^#{Regexp.escape(end_marker)}$/m
    desired = if content.match?(pattern)
      content.sub(pattern, block)
    elsif content.match?(/\n}\s*\z/)
      content.sub(/\n}\s*\z/, "\n\n#{block}\n}\n")
    else
      abort "Cannot find the menu object ending in #{path}"
    end

    if content == desired
      status("Suspend alias: sleep", ok: true)
      return
    end

    @changed = true
    @menu_changed = true
    status("Suspend alias: sleep → set", ok: false)
    return if @dry_run || @check

    backup(path)
    path.write(desired)
  rescue Errno::ENOENT => e
    abort "Cannot read #{path}: #{e.message}"
  end

  def ensure_keyboard_repeat
    path = @home.join(".config/hypr/input.lua")
    block = <<~LUA.chomp
      hl.config({
        input = {
          repeat_rate = #{KEY_REPEAT_RATE},
          repeat_delay = #{KEY_REPEAT_DELAY},
        },
      })
    LUA
    ensure_lua_block(
      path:,
      key: "keyboard repeat",
      block:,
      status_text: "Keyboard repeat: #{KEY_REPEAT_RATE}/s after #{KEY_REPEAT_DELAY}ms"
    )
  end

  def ensure_window_layout
    path = @home.join(".config/hypr/looknfeel.lua")
    block = <<~LUA.chomp
      hl.config({
        general = {
          layout = "#{WINDOW_LAYOUT}",
        },
      })
    LUA
    ensure_lua_block(path:, key: "window layout", block:, status_text: "Window layout: #{WINDOW_LAYOUT}")
  end

  def ensure_keybindings
    path = @home.join(".config/hypr/bindings.lua")
    block = <<~LUA.chomp
      o.bind("SUPER + Q", "Close window", hl.dsp.window.close())
    LUA
    ensure_lua_block(path:, key: "keybindings", block:, status_text: "SUPER+Q: close window")
  end

  def ensure_workspace_animation
    path = @home.join(".config/hypr/looknfeel.lua")
    block = <<~LUA.chomp
      hl.animation({
        leaf = "workspaces",
        enabled = true,
        speed = #{WORKSPACE_ANIMATION_SPEED},
        bezier = "easeOutQuint",
        style = "slidevert",
      })
    LUA
    ensure_lua_block(path:, key: "workspace animation", block:, status_text: "Workspace animation: vertical")
  end

  def ensure_lua_block(path:, key:, block:, status_text:)
    content = path.read
    start_marker = "-- dotfiles: #{key} start"
    end_marker = "-- dotfiles: #{key} end"
    managed_block = "#{start_marker}\n#{block}\n#{end_marker}"
    pattern = /^#{Regexp.escape(start_marker)}$.*?^#{Regexp.escape(end_marker)}$/m
    desired = content.match?(pattern) ? content.sub(pattern, managed_block) : "#{content.rstrip}\n\n#{managed_block}\n"

    if content == desired
      status(status_text, ok: true)
      return
    end

    @changed = true
    @hyprland_changed = true
    status("#{status_text} → set", ok: false)
    return if @dry_run || @check

    backup(path)
    path.write(desired)
  rescue Errno::ENOENT => e
    abort "Cannot read #{path}: #{e.message}"
  end

  def ensure_terminal
    installed = available?(TERMINAL)
    unless installed
      @changed = true
      status("Install Ghostty", ok: false)
      command("omarchy", "install", "terminal", TERMINAL) unless @dry_run || @check
    end

    current = capture("omarchy", "default", "terminal")
    ensure_setting("Default terminal", current:, desired: TERMINAL) do
      command("omarchy", "default", "terminal", TERMINAL)
    end
  end

  def ensure_opencode
    unless available?("opencode2")
      @changed = true
      status("Install OpenCode 2 CLI", ok: false)
      command("npm", "install", "-g", "@opencode-ai/cli@next") unless @dry_run || @check
    else
      status("OpenCode 2 CLI installed", ok: true)
    end

    unless package_installed?("opencode-desktop-bin")
      @changed = true
      status("Install OpenCode Desktop", ok: false)
      command_with_retries("omarchy", "pkg", "aur", "add", "opencode-desktop-bin") unless @dry_run || @check
    else
      status("OpenCode Desktop installed", ok: true)
    end
  end

  def ensure_setting(label, current:, desired:)
    if current.to_s.casecmp?(desired.to_s)
      status("#{label}: #{desired}", ok: true)
      return
    end

    @changed = true
    status("#{label}: #{current.inspect} → #{desired}", ok: false)
    yield unless @dry_run || @check
  end

  def validate_hyprland
    command("hyprctl", "reload")
    errors = capture("hyprctl", "configerrors")
    abort "Hyprland config errors:\n#{errors}" unless errors.empty?
  end

  def backup(path)
    return if @backed_up[path]

    backup_path = Pathname("#{path}.pre-dotfiles-#{Time.now.strftime('%Y%m%d-%H%M%S')}")
    FileUtils.cp(path, backup_path)
    @backed_up[path] = true
  end

  def capture(*command)
    output, status = Open3.capture2e({ "HOME" => @home.to_s }, *command)
    abort "Command failed: #{command.join(' ')}\n#{output}" unless status.success?

    output.strip
  end

  def command(*command)
    success = system({ "HOME" => @home.to_s }, *command)
    abort "Command failed: #{command.join(' ')}" unless success
  end

  def command_with_retries(*command, attempts: 3)
    attempts.times do |attempt|
      return if system({ "HOME" => @home.to_s }, *command)

      status("Retry #{attempt + 2}/#{attempts}", ok: false) if attempt + 1 < attempts
    end

    abort "Command failed after #{attempts} attempts: #{command.join(' ')}"
  end

  def heading(text)
    gum("style", "--bold", "--foreground", "12", text) || puts(text)
  end

  def status(text, ok:)
    prefix = ok ? "✓" : "→"
    color = ok ? "10" : "11"
    gum("style", "--foreground", color, "  #{prefix} #{text}") || puts("  #{prefix} #{text}")
  end

  def gum(*args)
    return false unless available?("gum")

    system("gum", *args)
  end

  def available?(command)
    ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).any? do |directory|
      File.executable?(File.join(directory, command))
    end
  end

  def package_installed?(package)
    system("pacman", "-Q", package, out: File::NULL, err: File::NULL)
  end
end

OmarchySetup.new(ARGV).run
