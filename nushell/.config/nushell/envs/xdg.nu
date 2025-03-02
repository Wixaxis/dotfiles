# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

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

# XDG user directories - using macOS standard paths
# Note: On macOS these are typically in ~/Library but we'll keep them in home for XDG compatibility
$env.XDG_DESKTOP_DIR = ($env.HOME | path join 'Desktop')      # Pulpit
$env.XDG_DOCUMENTS_DIR = ($env.HOME | path join 'Documents')  # Dokumenty
$env.XDG_DOWNLOAD_DIR = ($env.HOME | path join 'Downloads')   # Pobrane
$env.XDG_MUSIC_DIR = ($env.HOME | path join 'Music')         # Muzyka
$env.XDG_PICTURES_DIR = ($env.HOME | path join 'Pictures')    # Zdjęcia
$env.XDG_VIDEOS_DIR = ($env.HOME | path join 'Movies')       # Filmy

# Create user directories if they don't exist
create_if_missing $env.XDG_DESKTOP_DIR
create_if_missing $env.XDG_DOCUMENTS_DIR
create_if_missing $env.XDG_DOWNLOAD_DIR
create_if_missing $env.XDG_MUSIC_DIR
create_if_missing $env.XDG_PICTURES_DIR
create_if_missing $env.XDG_VIDEOS_DIR

# macOS-specific system-wide directories
if not ('XDG_DATA_DIRS' in $env) {
    $env.XDG_DATA_DIRS = '/usr/local/share:/usr/share:/Library/Application Support'
}

if not ('XDG_CONFIG_DIRS' in $env) {
    $env.XDG_CONFIG_DIRS = '/etc/xdg:/Library/Preferences'
}

# For macOS, we'll use a more appropriate runtime directory
if not ('XDG_RUNTIME_DIR' in $env) {
    $env.XDG_RUNTIME_DIR = ($env.HOME | path join 'Library' 'Application Support' 'RuntimeDir')
    create_if_missing $env.XDG_RUNTIME_DIR
}

