#!/usr/bin/env -S mise exec ruby -- ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "shellwords"
require "socket"
require "time"
require "yaml"

module DotfilesStateCapture
  module_function

  def repo_root
    Pathname(__dir__).parent.realpath
  end

  def home
    Pathname(ENV.fetch("DOTFILES_HOME", ENV.fetch("HOME"))).expand_path
  end

  def os
    ENV["DOTFILES_OS"] || (RUBY_PLATFORM.match?(/darwin/) ? "macos" : "linux")
  end

  def distro
    return ENV["DOTFILES_DISTRO"] if ENV["DOTFILES_DISTRO"]
    return "macos" if os == "macos"
    return "arch" if File.exist?("/etc/arch-release")

    return "linux" unless File.exist?("/etc/os-release")

    id = File.read("/etc/os-release")[/^ID=(.+)$/, 1]
    id.to_s.delete('"').strip.empty? ? "linux" : id.to_s.delete('"').strip
  end

  def desktop
    return ENV["DOTFILES_DESKTOP"] if ENV["DOTFILES_DESKTOP"]
    return "none" if os == "macos"

    current = ENV["XDG_CURRENT_DESKTOP"].to_s
    session = ENV["XDG_SESSION_DESKTOP"].to_s
    return "gnome" if current.include?("GNOME") || session.downcase.include?("gnome")
    return "hyprland" if !ENV["HYPRLAND_INSTANCE"].to_s.empty? || current.include?("Hyprland")

    "other"
  end

  def context_hash
    {
      repo_root: repo_root.to_s,
      home: home.to_s,
      hostname: Socket.gethostname,
      os:,
      distro:,
      desktop:,
      captured_at: Time.now.iso8601
    }
  end

  def selectors_match?(selectors)
    return true if selectors.nil? || selectors.empty?

    selectors.all? do |key, expected|
      actual =
        case key.to_s
        when "os" then os
        when "distro" then distro
        when "desktop" then desktop
        else false
        end

      Array(expected).map(&:to_s).include?(actual)
    end
  end

  def package_manifests
    Dir.glob(repo_root.join("packages", "*", "*", "setup.yaml").to_s).sort.map do |path|
      root = Pathname(path).dirname
      manifest = YAML.safe_load(File.read(path), aliases: true) || {}
      {
        identifier: "#{root.parent.basename}/#{manifest.fetch("name")}",
        root:,
        manifest:
      }
    end
  end

  def applicable_packages
    package_manifests.select do |package|
      package[:manifest].fetch("state", "active") == "active" &&
        selectors_match?(package[:manifest]["applies_when"] || {})
    end
  end

  def expand_target(raw_target)
    return Pathname(raw_target.sub(/\A~\//, "#{home}/")).expand_path if raw_target.start_with?("~/")

    home.join(raw_target)
  end

  def managed_entries(packages)
    packages.flat_map do |package|
      package[:manifest].fetch("links", []).flat_map do |entry|
        next [] unless selectors_match?(entry["applies_when"] || {})

        source_root = package[:root].join(entry.fetch("source"))
        target_root = expand_target(entry.fetch("target"))
        mode = entry.fetch("mode")

        case mode
        when "file", "tree"
          [
            {
              package: package[:identifier],
              mode:,
              kind: "path",
              source: source_root.to_s,
              target: target_root.to_s
            }
          ]
        when "children"
          child_entries_for(package[:identifier], source_root, target_root, mode)
        else
          []
        end
      end
    end
  end

  def child_entries_for(identifier, source_root, target_root, mode)
    entries = [
      {
        package: identifier,
        mode:,
        kind: "root-directory",
        source: source_root.to_s,
        target: target_root.to_s
      }
    ]

    Dir.glob(source_root.join("**", "*").to_s, File::FNM_DOTMATCH).sort.each do |path|
      next if path.end_with?("/.", "/..")

      source = Pathname(path)
      relative = source.relative_path_from(source_root)
      target = target_root.join(relative)
      kind = source.directory? ? "directory" : "file"

      entries << {
        package: identifier,
        mode:,
        kind:,
        source: source.to_s,
        target: target.to_s
      }
    end

    entries
  end

  def interesting_roots(packages)
    packages.flat_map do |package|
      package[:manifest].fetch("links", []).flat_map do |entry|
        next [] unless selectors_match?(entry["applies_when"] || {})

        source_root = package[:root].join(entry.fetch("source"))
        target_root = expand_target(entry.fetch("target"))

        case entry.fetch("mode")
        when "children"
          children = Dir.children(source_root).sort.reject { |child| child == "." || child == ".." }
          children.empty? ? [target_root.to_s] : children.map { |child| target_root.join(child).to_s }
        else
          [target_root.to_s]
        end
      end
    end.uniq.sort
  end

  def path_state(path)
    pathname = Pathname(path)

    state = {
      path: pathname.to_s,
      exists: pathname.exist?,
      symlink: pathname.symlink?,
      directory: pathname.directory?,
      file: pathname.file?
    }

    if pathname.symlink?
      state[:readlink] = pathname.readlink.to_s rescue nil
      state[:resolved_path] = pathname.realpath.to_s rescue nil
    end

    state
  end

  def tree_dump(path)
    pathname = Pathname(path)
    lines = []
    lines << "$ ls -ld #{pathname}"
    lines << capture_shell("ls -ld #{Shellwords.escape(pathname.to_s)}")

    return lines.join("\n") unless pathname.exist? || pathname.symlink?
    return lines.join("\n") unless pathname.directory? || (pathname.symlink? && pathname.exist? && pathname.realpath.directory?)

    lines << ""
    lines << "$ find -H #{pathname} -maxdepth 2 -mindepth 1 -exec ls -ld {} \\;"
    lines << capture_shell("find -H #{Shellwords.escape(pathname.to_s)} -maxdepth 2 -mindepth 1 -exec ls -ld {} \\; | sort")
    lines.join("\n")
  end

  def capture_shell(command)
    output, = Open3.capture2e(command, chdir: repo_root.to_s)
    output.strip
  end

  def capture_command(*command)
    output, status = Open3.capture2e(*command, chdir: repo_root.to_s)
    {
      command: command.join(" "),
      exit_code: status.exitstatus || 1,
      output:
    }
  end

  def write_json(path, payload)
    path.write(JSON.pretty_generate(payload) + "\n")
  end

  def write_text(path, payload)
    path.write(payload)
  end

  def build_summary(snapshot_dir:, context:, applicable:, command_results:, roots:, root_states:)
    lines = []
    lines << "# Dotfiles State Snapshot"
    lines << ""
    lines << "- Label: `#{snapshot_dir.basename}`"
    lines << "- Captured at: `#{context[:captured_at]}`"
    lines << "- Hostname: `#{context[:hostname]}`"
    lines << "- OS: `#{context[:os]}`"
    lines << "- Distro: `#{context[:distro]}`"
    lines << "- Desktop: `#{context[:desktop]}`"
    lines << "- Home: `#{context[:home]}`"
    lines << ""
    lines << "## Applicable Packages"
    applicable.each { |package| lines << "- `#{package[:identifier]}`" }
    lines << ""
    lines << "## Command Status"
    command_results.each do |name, result|
      lines << "- `#{name}`: exit `#{result[:exit_code]}`"
    end
    lines << ""
    lines << "## Interesting Roots"
    roots.each do |root|
      state = root_states[root]
      label =
        if state[:symlink]
          "symlink -> #{state[:readlink] || "unresolved"}"
        elsif state[:directory]
          "directory"
        elsif state[:file]
          "file"
        else
          "missing"
        end

      lines << "- `#{root}`: #{label}"
    end
    lines << ""
    lines << "## Raw Files"
    lines << "- `metadata.json`"
    lines << "- `applicable-packages.txt`"
    lines << "- `managed-targets.json`"
    lines << "- `root-states.json`"
    lines << "- `setup-list.txt`"
    lines << "- `setup-check.txt`"
    lines << "- `setup-dry-run.txt`"
    lines << "- `trees.txt`"
    lines.join("\n") + "\n"
  end

  def snapshot_label(raw_label)
    raw = raw_label.to_s.strip
    raw.empty? ? "snapshot" : raw.downcase.gsub(/[^a-z0-9._-]+/, "-").gsub(/\A-+|-+\z/, "")
  end

  def run(label)
    timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
    snapshot_dir = repo_root.join("local", "snapshots", "#{timestamp}-#{snapshot_label(label)}")
    FileUtils.mkdir_p(snapshot_dir)

    context = context_hash
    applicable = applicable_packages
    commands = {
      "setup-list" => capture_command("./setup.sh", "--list"),
      "setup-check" => capture_command("./setup.sh", "--check"),
      "setup-dry-run" => capture_command("./setup.sh", "--dry-run", "--no-install")
    }

    entries = managed_entries(applicable)
    roots = interesting_roots(applicable)
    root_states = roots.each_with_object({}) { |root, hash| hash[root] = path_state(root) }
    trees = roots.map { |root| tree_dump(root) }.join("\n\n" + ("-" * 80) + "\n\n")

    write_json(snapshot_dir.join("metadata.json"), context)
    write_text(snapshot_dir.join("applicable-packages.txt"), applicable.map { |package| package[:identifier] }.join("\n") + "\n")
    write_json(snapshot_dir.join("managed-targets.json"), entries)
    write_json(snapshot_dir.join("root-states.json"), root_states)
    write_text(snapshot_dir.join("setup-list.txt"), commands["setup-list"][:output])
    write_text(snapshot_dir.join("setup-check.txt"), commands["setup-check"][:output])
    write_text(snapshot_dir.join("setup-dry-run.txt"), commands["setup-dry-run"][:output])
    write_text(snapshot_dir.join("trees.txt"), trees + "\n")
    write_text(
      snapshot_dir.join("summary.md"),
      build_summary(
        snapshot_dir:,
        context:,
        applicable:,
        command_results: commands,
        roots:,
        root_states:
      )
    )

    puts snapshot_dir
  end
end

label = ARGV.join(" ").strip
DotfilesStateCapture.run(label.empty? ? "snapshot" : label)
