#!/usr/bin/env -S mise exec ruby@latest -- ruby
# frozen_string_literal: true

require 'json'
require 'pathname'

script_file = Pathname.new(__FILE__).realpath
scripts_dir = script_file.dirname
dotfiles_root = scripts_dir.parent.parent
justfile_path = dotfiles_root.join('justfile', 'justfile')
launcher_path = Pathname.new(File.join(Dir.home, 'scripts', script_file.basename.to_s))

require scripts_dir.join('ruby', 'handle_dmenu').to_s

ghostty_bin = begin
  resolved = `command -v ghostty 2>/dev/null`.strip
  if !resolved.empty?
    resolved
  else
    app_binary = '/Applications/Ghostty.app/Contents/MacOS/ghostty'
    app_binary if File.executable?(app_binary)
  end
end

opts = {}

JSON.parse(`just -f #{justfile_path} --dump --dump-format json`)['recipes'].each do |name, options|
  callback = if options['quiet']
               lambda {
                 close_dmenu
                 system('just', '-f', justfile_path.to_s, name)
               }
             else
               lambda {
                 close_dmenu
                 if ghostty_bin
                   system(ghostty_bin, '-e', 'nu', '-c', "just -f #{justfile_path} #{name}")
                 else
                   system('nu', '-c', "just -f #{justfile_path} #{name}")
                 end
               }
             end
  opts[name.to_sym] = callback unless name[0] == '_'
end

handle_dmenu opts:, modename: 'just', path: launcher_path.to_s
