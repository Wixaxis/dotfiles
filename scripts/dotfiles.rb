#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "find"
require "optparse"
require "pathname"
require "tmpdir"
require "yaml"

module Dotfiles
  class Error < StandardError; end

  Link = Struct.new(
    :source,
    :target,
    :mode,
    :create_parents,
    :backup_on_conflict,
    :applies_when,
    keyword_init: true
  )

  class Context
    attr_reader :repo_root, :home, :os, :distro, :desktop

    def initialize(repo_root:, home:, os:, distro:, desktop:)
      @repo_root = Pathname(repo_root).realpath
      @home = Pathname(home).expand_path
      @os = os
      @distro = distro
      @desktop = desktop
    end

    def self.detect(repo_root)
      os = ENV["DOTFILES_OS"] || detect_os
      distro = ENV["DOTFILES_DISTRO"] || detect_distro(os)
      desktop = ENV["DOTFILES_DESKTOP"] || detect_desktop(os)
      home = ENV["DOTFILES_HOME"] || ENV.fetch("HOME")
      new(repo_root:, home:, os:, distro:, desktop:)
    end

    def pretty_label
      desktop_suffix = desktop == "none" ? "" : " / #{desktop}"
      "#{os} / #{distro}#{desktop_suffix}"
    end

    def selector_matches?(selectors)
      return true if selectors.nil? || selectors.empty?

      selectors.all? do |key, expected|
        current =
          case key.to_s
          when "os" then os
          when "distro" then distro
          when "desktop" then desktop
          else
            raise Error, "Unknown selector key: #{key}"
          end

        expected_values = Array(expected).map(&:to_s)
        expected_values.include?(current)
      end
    end

    def env_hash
      {
        "DOTFILES_HOME" => home.to_s,
        "DOTFILES_OS" => os,
        "DOTFILES_DISTRO" => distro,
        "DOTFILES_DESKTOP" => desktop
      }
    end

    def self.detect_os
      case RUBY_PLATFORM
      when /darwin/
        "macos"
      else
        "linux"
      end
    end
    private_class_method :detect_os

    def self.detect_distro(os)
      return "macos" if os == "macos"
      return "arch" if File.exist?("/etc/arch-release")

      if File.exist?("/etc/os-release")
        id = File.read("/etc/os-release")[/^ID=(.+)$/, 1]
        return id.to_s.delete('"').strip unless id.nil? || id.empty?
      end

      "linux"
    end
    private_class_method :detect_distro

    def self.detect_desktop(os)
      return "none" if os == "macos"

      current = ENV["XDG_CURRENT_DESKTOP"].to_s
      session = ENV["XDG_SESSION_DESKTOP"].to_s
      return "gnome" if current.include?("GNOME") || session.downcase.include?("gnome")
      return "hyprland" if !ENV["HYPRLAND_INSTANCE"].to_s.empty? || current.include?("Hyprland")

      "other"
    end
    private_class_method :detect_desktop
  end

  class Package
    attr_reader :root, :manifest

    def initialize(root)
      @root = Pathname(root).realpath
      @manifest = YAML.safe_load(root.join("setup.yaml").read, aliases: true) || {}
    end

    def self.discover(repo_root)
      Dir.glob(repo_root.join("packages", "*", "*", "setup.yaml").to_s)
        .sort
        .map { |path| new(Pathname(path).dirname) }
    end

    def name
      manifest.fetch("name")
    end

    def scope
      root.parent.basename.to_s
    end

    def identifier
      "#{scope}/#{name}"
    end

    def description
      manifest["description"].to_s
    end

    def state
      manifest.fetch("state", "active")
    end

    def engine
      manifest.fetch("engine", "native")
    end

    def stow_root
      root.join("stow")
    end

    def setup_script
      root.join("setup.sh")
    end

    def check_script
      root.join("is_stowed.sh")
    end

    def hooks
      manifest.fetch("hooks", [])
    end

    def applies_when
      manifest.fetch("applies_when", {})
    end

    def install_spec
      manifest.fetch("install", {})
    end

    def applicable?(context)
      return false if state != "active"

      context.selector_matches?(applies_when)
    end

    def selectable?(context)
      context.selector_matches?(applies_when)
    end

    def link_entries(context)
      manifest.fetch("links", []).filter_map do |entry|
        next unless context.selector_matches?(entry["applies_when"])

        Link.new(
          source: root.join(entry.fetch("source")),
          target: entry.fetch("target"),
          mode: entry.fetch("mode"),
          create_parents: entry.fetch("create_parents", true),
          backup_on_conflict: entry.fetch("backup_on_conflict", true),
          applies_when: entry["applies_when"] || {}
        )
      end
    end
  end

  class UI
    def initialize(auto_yes:, dry_run:)
      @auto_yes = auto_yes
      @dry_run = dry_run
    end

    def info(message)
      puts "INFO #{message}"
    end

    def success(message)
      puts "OK   #{message}"
    end

    def warn(message)
      puts "WARN #{message}"
    end

    def error(message)
      warn("ERROR #{message}")
    end

    def heading(message)
      puts
      puts "== #{message} =="
    end

    def confirm(message, default: false)
      return true if @auto_yes || @dry_run

      if $stdin.tty? && $stdout.tty? && system("command -v gum >/dev/null 2>&1")
        system("gum", "confirm", message)
      elsif !$stdin.tty? || !$stdout.tty?
        default
      else
        answer = default ? "Y/n" : "y/N"
        print "#{message} [#{answer}] "
        response = $stdin.gets.to_s.strip.downcase
        if default
          !response.start_with?("n")
        else
          response.start_with?("y")
        end
      end
    end
  end

  class Installer
    def initialize(context:, ui:, dry_run:, skip_install:)
      @context = context
      @ui = ui
      @dry_run = dry_run
      @skip_install = skip_install
    end

    def install_missing_for(packages)
      return if @skip_install

      packages.each do |package|
        spec = current_spec(package)
        next if spec.nil? || spec.empty?

        missing = missing_packages(spec)
        next if missing.empty?

        @ui.warn("#{package.identifier}: missing packages #{missing.join(', ')}")
        next unless @ui.confirm("Install missing packages for #{package.identifier}?", default: false)

        install(spec)
      end
    end

    private

    def current_spec(package)
      package.install_spec[@context.distro] || package.install_spec[@context.os]
    end

    def missing_packages(spec)
      case spec["manager"]
      when "brew"
        missing_brew(spec)
      when "paru", "pacman"
        missing_arch(spec)
      else
        []
      end
    end

    def missing_arch(spec)
      Array(spec["packages"]).reject do |name|
        system("pacman", "-Qi", name, out: File::NULL, err: File::NULL)
      end
    end

    def missing_brew(spec)
      missing = []
      Array(spec["formulae"]).each do |name|
        missing << name unless system("brew", "list", "--formula", name, out: File::NULL, err: File::NULL)
      end
      Array(spec["casks"]).each do |name|
        missing << name unless system("brew", "list", "--cask", name, out: File::NULL, err: File::NULL)
      end
      missing
    end

    def install(spec)
      case spec["manager"]
      when "brew"
        Array(spec["formulae"]).each { |name| run(%W[brew install #{name}]) }
        Array(spec["casks"]).each { |name| run(%W[brew install --cask #{name}]) }
      when "paru"
        Array(spec["packages"]).each { |name| run(%W[paru -S --noconfirm #{name}]) }
      when "pacman"
        Array(spec["packages"]).each { |name| run(%W[sudo pacman -S --noconfirm #{name}]) }
      end
    end

    def run(command)
      if @dry_run
        @ui.info("dry-run: #{command.join(' ')}")
      else
        system(*command) || raise(Error, "Command failed: #{command.join(' ')}")
      end
    end
  end

  class Runner
    def initialize(context:, ui:, dry_run:, package_filters:, skip_install:)
      @context = context
      @ui = ui
      @dry_run = dry_run
      @package_filters = package_filters
      @skip_install = skip_install
    end

    def list(packages)
      packages.each do |package|
        puts [
          package.identifier,
          package.state,
          package.applicable?(@context) ? "applicable" : "not-applicable",
          package.description
        ].join("\t")
      end
    end

    def apply(packages)
      applicable = selected_packages(packages).select { |package| package.applicable?(@context) }
      if applicable.empty?
        @ui.warn("No active packages matched #{@context.pretty_label}")
        return true
      end

      @ui.heading("Package Plan")
      applicable.each do |package|
        @ui.info("#{package.identifier} (#{package.engine})")
      end

      installer.install_missing_for(applicable)

      return true unless @ui.confirm("Apply #{applicable.length} package(s)?", default: true)

      failures = []
      applicable.each do |package|
        @ui.heading("Applying #{package.identifier}")
        begin
          apply_package(package)
          @ui.success("#{package.identifier} applied")
        rescue Error => error
          failures << [package.identifier, error.message]
          @ui.error("#{package.identifier}: #{error.message}")
        end
      end

      summarize_failures(failures)
    end

    def check(packages)
      applicable = selected_packages(packages)
      applicable = if @package_filters.empty?
                     applicable.select { |package| package.applicable?(@context) }
                   else
                     applicable.select { |package| package.selectable?(@context) }
                   end
      failures = []

      applicable.each do |package|
        if authoritative_check(package)
          @ui.success("#{package.identifier} check passed")
        else
          failures << [package.identifier, "authoritative check failed"]
          @ui.error("#{package.identifier} check failed")
        end
      end

      summarize_failures(failures)
    end

    def generic_check_all(packages)
      applicable = selected_packages(packages).select { |package| package.selectable?(@context) }
      failures = []

      applicable.each do |package|
        if generic_check(package)
          @ui.success("#{package.identifier} generic check passed")
        else
          failures << [package.identifier, "generic check failed"]
          @ui.error("#{package.identifier} generic check failed")
        end
      end

      summarize_failures(failures)
    end

    def apply_single(package)
      apply([package])
    end

    def generic_check(package)
      package.link_entries(@context).all? { |link| check_link(link) }
    end

    private

    def installer
      @installer ||= Installer.new(
        context: @context,
        ui: @ui,
        dry_run: @dry_run,
        skip_install: @skip_install
      )
    end

    def selected_packages(packages)
      return packages if @package_filters.empty?

      selected = packages.select do |package|
        @package_filters.include?(package.name) ||
          @package_filters.include?(package.identifier)
      end

      return selected unless selected.empty?

      raise Error, "No packages matched filter(s): #{@package_filters.join(', ')}"
    end

    def summarize_failures(failures)
      return true if failures.empty?

      @ui.heading("Failures")
      failures.each { |identifier, message| @ui.error("#{identifier}: #{message}") }
      false
    end

    def apply_package(package)
      if @dry_run
        run_hook(package, "pre_link")
        package.link_entries(@context).each { |link| apply_link(link) }
        run_hook(package, "post_link")
        return
      end

      run_hook(package, "pre_link")

      case package.engine
      when "native"
        package.link_entries(@context).each { |link| apply_link(link) }
      when "stow"
        apply_with_stow(package)
      else
        raise Error, "Unsupported engine #{package.engine.inspect}"
      end

      run_hook(package, "post_link")

      raise Error, "authoritative check failed" unless authoritative_check(package)
    end

    def run_hook(package, phase)
      return unless package.hooks.include?(phase)
      return unless package.setup_script.exist?

      if @dry_run
        @ui.info("dry-run: #{package.setup_script} #{phase}")
        return
      end

      success = system(
        @context.env_hash,
        package.setup_script.to_s,
        phase,
        chdir: package.root.to_s
      )
      raise Error, "#{phase} hook failed" unless success
    end

    def authoritative_check(package)
      return generic_check(package) unless package.check_script.exist?

      system(
        @context.env_hash,
        package.check_script.to_s,
        chdir: package.root.to_s
      )
    end

    def apply_with_stow(package)
      raise Error, "stow is not installed" unless system("command -v stow >/dev/null 2>&1")

      if @dry_run
        @ui.info("dry-run: stow #{package.identifier}")
        return
      end

      Dir.mktmpdir("dotfiles-stow") do |tmpdir|
        package_dir = File.join(tmpdir, package.name)
        File.symlink(package.stow_root.to_s, package_dir)
        success = system("stow", "--dir", tmpdir, "--target", @context.home.to_s, package.name)
        raise Error, "stow failed" unless success
      end
    end

    def apply_link(link)
      source = link.source.realpath
      target = expand_target(link.target)

      case link.mode
      when "file"
        create_parents(target) if link.create_parents
        link_path(source, target, backup_on_conflict: link.backup_on_conflict)
      when "tree"
        create_parents(target.parent) if link.create_parents
        link_path(source, target, backup_on_conflict: link.backup_on_conflict)
      when "children"
        link_children(source, target, backup_on_conflict: link.backup_on_conflict)
      else
        raise Error, "Unsupported link mode #{link.mode.inspect}"
      end
    end

    def check_link(link)
      source = link.source.realpath
      target = expand_target(link.target)

      case link.mode
      when "file", "tree"
        symlink_points_to?(target, source)
      when "children"
        check_children(source, target)
      else
        false
      end
    end

    def link_children(source_root, target_root, backup_on_conflict:)
      if target_root.symlink?
        ensure_conflict_resolved(target_root, backup_on_conflict:)
      elsif target_root.exist? && !target_root.directory?
        ensure_conflict_resolved(target_root, backup_on_conflict:)
      end

      create_dir(target_root)

      Find.find(source_root.to_s) do |raw_path|
        path = Pathname(raw_path)
        next if path == source_root

        relative = path.relative_path_from(source_root)
        target = target_root.join(relative)

        if path.directory?
          if target.symlink? || (target.exist? && !target.directory?)
            ensure_conflict_resolved(target, backup_on_conflict:)
          end
          create_dir(target)
        else
          create_dir(target.parent)
          link_path(path, target, backup_on_conflict:)
        end
      end
    end

    def check_children(source_root, target_root)
      return false unless target_root.directory? && !target_root.symlink?

      Find.find(source_root.to_s) do |raw_path|
        path = Pathname(raw_path)
        next if path == source_root

        relative = path.relative_path_from(source_root)
        target = target_root.join(relative)

        if path.directory?
          return false unless target.directory? && !target.symlink?
        else
          return false unless symlink_points_to?(target, path.realpath)
        end
      end

      true
    end

    def link_path(source, target, backup_on_conflict:)
      if symlink_points_to?(target, source)
        @ui.info("already linked: #{target}")
        return
      end

      if target.exist? || target.symlink?
        ensure_conflict_resolved(target, backup_on_conflict:)
      end

      if @dry_run
        @ui.info("dry-run: ln -s #{source} #{target}")
      else
        File.symlink(source.to_s, target.to_s)
      end
    end

    def ensure_conflict_resolved(path, backup_on_conflict:)
      raise Error, "conflict at #{path}" unless backup_on_conflict

      confirmed = @ui.confirm("Back up existing #{path} and replace it?", default: false)
      raise Error, "conflict not resolved at #{path}" unless confirmed

      backup_path = Pathname("#{path}.pre-dotfiles-#{Time.now.strftime('%Y%m%d-%H%M%S')}")
      if @dry_run
        @ui.info("dry-run: mv #{path} #{backup_path}")
      else
        FileUtils.mkdir_p(backup_path.parent)
        FileUtils.mv(path.to_s, backup_path.to_s)
      end
    end

    def create_parents(path)
      create_dir(path.parent)
    end

    def create_dir(path)
      return if path.directory?
      return if path == @context.home

      if path.symlink? || path.exist?
        ensure_conflict_resolved(path, backup_on_conflict: true)
      end

      if @dry_run
        @ui.info("dry-run: mkdir -p #{path}")
      else
        FileUtils.mkdir_p(path)
      end
    end

    def expand_target(raw_target)
      return Pathname(raw_target.sub(/\A~\//, "#{@context.home}/")).expand_path if raw_target.start_with?("~/")

      @context.home.join(raw_target)
    end

    def symlink_points_to?(target, source)
      target.symlink? && target.realpath == Pathname(source).realpath
    rescue Errno::ENOENT, Errno::ENOTDIR
      false
    end
  end

  class CLI
    def initialize(argv)
      @argv = argv
    end

    def run
      options = {
        mode: :apply,
        dry_run: false,
        auto_yes: env_yes?,
        package_filters: [],
        package_path: nil,
        skip_install: false
      }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: dotfiles.rb [options]"
        opts.on("--check", "Run authoritative checks instead of applying") { options[:mode] = :check }
        opts.on("--generic-check", "Run manifest-based checks only") { options[:mode] = :generic_check }
        opts.on("--dry-run", "Print actions without mutating anything") { options[:dry_run] = true }
        opts.on("--list", "List discovered packages") { options[:mode] = :list }
        opts.on("--yes", "Auto-confirm prompts") { options[:auto_yes] = true }
        opts.on("--no-install", "Skip package-manager installation prompts") { options[:skip_install] = true }
        opts.on("--package NAME", "Limit to a package name or scope/name") { |value| options[:package_filters] << value }
        opts.on("--package-path PATH", "Operate on a package directory directly") { |value| options[:package_path] = value }
      end

      parser.parse!(@argv)

      repo_root = Pathname(__dir__).parent
      context = Context.detect(repo_root)
      ui = UI.new(auto_yes: options[:auto_yes], dry_run: options[:dry_run])
      packages = load_packages(repo_root, options)
      runner = Runner.new(
        context:,
        ui:,
        dry_run: options[:dry_run],
        package_filters: options[:package_filters],
        skip_install: options[:skip_install]
      )

      ok =
        case options[:mode]
        when :list
          runner.list(packages)
          true
        when :generic_check
          runner.generic_check_all(packages)
        when :check
          runner.check(packages)
        else
          runner.apply(packages)
        end

      exit(ok ? 0 : 1)
    rescue Error => error
      warn("ERROR #{error.message}")
      exit(1)
    end

    private

    def load_packages(repo_root, options)
      if options[:package_path]
        [Package.new(Pathname(options[:package_path]))]
      else
        Package.discover(repo_root)
      end
    end

    def env_yes?
      %w[1 true yes].include?(ENV["DOTFILES_YES"].to_s.downcase)
    end
  end
end

Dotfiles::CLI.new(ARGV).run
