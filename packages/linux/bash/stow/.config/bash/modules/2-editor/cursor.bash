export PATH=$HOME/.local/bin:$PATH

# Cursor agent compatibility: stub function for dump_bash_state
# Cursor's agent tries to call this to capture shell state, but it doesn't exist by default
# This is called by Cursor's command wrapper in non-interactive shells
dump_bash_state() {
    # Stub function to prevent "command not found" errors from Cursor agent
    # This is called by Cursor's command wrapper but doesn't need to do anything
    :
}
# Export function so it's available in non-interactive shells if Cursor sources this
export -f dump_bash_state 2>/dev/null || true
