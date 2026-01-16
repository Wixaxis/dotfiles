# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
# 
# Note: XDG is a Linux standard. On macOS, applications typically use ~/Library paths.
# This configuration is Linux-only to avoid conflicts with macOS conventions.

# Only set up XDG on Linux systems
if ($nu.os-info.name == "linux") {
    # Helper function to create directory if it doesn't exist
    def create_if_missing [dir: string] {
        if not ($dir | path exists) {
            mkdir $dir
            print $"Created directory: ($dir)"
        }
    }

    # Set default values for XDG Base Directory variables
    $env.XDG_DATA_HOME = ($env.HOME | path join '.local' 'share')
    $env.XDG_CONFIG_HOME = ($env.HOME | path join '.config')
    $env.XDG_STATE_HOME = ($env.HOME | path join '.local' 'state')
    $env.XDG_CACHE_HOME = ($env.HOME | path join '.cache')

    # Create base XDG directories
    create_if_missing $env.XDG_DATA_HOME
    create_if_missing $env.XDG_CONFIG_HOME
    create_if_missing $env.XDG_STATE_HOME
    create_if_missing $env.XDG_CACHE_HOME

    # XDG user directories
    $env.XDG_DESKTOP_DIR = ($env.HOME | path join 'Desktop')
    $env.XDG_DOCUMENTS_DIR = ($env.HOME | path join 'Documents')
    $env.XDG_DOWNLOAD_DIR = ($env.HOME | path join 'Downloads')
    $env.XDG_MUSIC_DIR = ($env.HOME | path join 'Music')
    $env.XDG_PICTURES_DIR = ($env.HOME | path join 'Pictures')
    $env.XDG_VIDEOS_DIR = ($env.HOME | path join 'Videos')

    # Create user directories if they don't exist
    create_if_missing $env.XDG_DESKTOP_DIR
    create_if_missing $env.XDG_DOCUMENTS_DIR
    create_if_missing $env.XDG_DOWNLOAD_DIR
    create_if_missing $env.XDG_MUSIC_DIR
    create_if_missing $env.XDG_PICTURES_DIR
    create_if_missing $env.XDG_VIDEOS_DIR

    # XDG system directories (Linux defaults)
    if not ('XDG_DATA_DIRS' in $env) {
        $env.XDG_DATA_DIRS = '/usr/local/share/:/usr/share/'
    }

    if not ('XDG_CONFIG_DIRS' in $env) {
        $env.XDG_CONFIG_DIRS = '/etc/xdg'
    }

    if not ('XDG_RUNTIME_DIR' in $env) {
        $env.XDG_RUNTIME_DIR = $"/run/user/($env.USER)"
    }
}

