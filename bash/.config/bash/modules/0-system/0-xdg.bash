# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Helper function to create directory if it doesn't exist
_create_xdg_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        [ "${DEBUG:-false}" = "true" ] && echo "Created directory: $1"
    fi
}

# Create base XDG directories
_create_xdg_dir "$XDG_DATA_HOME"
_create_xdg_dir "$XDG_CONFIG_HOME"
_create_xdg_dir "$XDG_STATE_HOME"
_create_xdg_dir "$XDG_CACHE_HOME"

# XDG user directories
export XDG_DESKTOP_DIR="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
export XDG_DOCUMENTS_DIR="${XDG_DOCUMENTS_DIR:-$HOME/Documents}"
export XDG_DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
export XDG_MUSIC_DIR="${XDG_MUSIC_DIR:-$HOME/Music}"
export XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
export XDG_VIDEOS_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}"

# Create user directories if they don't exist
_create_xdg_dir "$XDG_DESKTOP_DIR"
_create_xdg_dir "$XDG_DOCUMENTS_DIR"
_create_xdg_dir "$XDG_DOWNLOAD_DIR"
_create_xdg_dir "$XDG_MUSIC_DIR"
_create_xdg_dir "$XDG_PICTURES_DIR"
_create_xdg_dir "$XDG_VIDEOS_DIR"

# XDG system directories (platform-aware)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific system-wide directories
    export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share:/Library/Application Support}"
    export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg:/Library/Preferences}"
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-$HOME/Library/Application Support/RuntimeDir}"
else
    # Linux defaults
    export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share/:/usr/share/}"
    export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg}"
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"
fi

# Create runtime directory if needed
if [[ "$OSTYPE" == "darwin"* ]]; then
    _create_xdg_dir "$XDG_RUNTIME_DIR"
fi

# File opening helper (for compatibility)
_open_files_for_editing() {
    if [ -x /usr/bin/exo-open ] ; then
        echo "exo-open $@" >&2
        setsid exo-open "$@" >& /dev/null
        return
    fi
    if [ -x /usr/bin/xdg-open ] ; then
        for file in "$@" ; do
            echo "xdg-open $file" >&2
            setsid xdg-open "$file" >& /dev/null
        done
        return
    fi

    echo "$FUNCNAME: package 'xdg-utils' or 'exo' is required." >&2
}

