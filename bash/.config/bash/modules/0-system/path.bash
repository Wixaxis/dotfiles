# Path management - ported from nushell path.nu
# Ensures common binary paths are in PATH

# Add local bin directory (user-installed binaries)
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# mise manages PATH automatically via activation, no manual PATH setup needed

# Add Ruby gem bin directory (platform-aware)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: typically in ~/.local/share/gem/ruby/VERSION/bin
    RUBY_VERSION=$(ruby -v 2>/dev/null | awk '{print $2}' | cut -d'p' -f1)
    if [ -n "$RUBY_VERSION" ] && [ -d "$HOME/.local/share/gem/ruby/$RUBY_VERSION/bin" ]; then
        GEM_BIN="$HOME/.local/share/gem/ruby/$RUBY_VERSION/bin"
        if [[ ":$PATH:" != *":$GEM_BIN:"* ]]; then
            export PATH="$GEM_BIN:$PATH"
        fi
    fi
else
    # Linux: check common locations
    if [ -d "$HOME/.local/share/gem/ruby/3.3.0/bin" ] && [[ ":$PATH:" != *":$HOME/.local/share/gem/ruby/3.3.0/bin:"* ]]; then
        export PATH="$HOME/.local/share/gem/ruby/3.3.0/bin:$PATH"
    fi
fi
