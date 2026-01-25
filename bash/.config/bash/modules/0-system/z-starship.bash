# Starship prompt configuration
# Cross-shell prompt that follows Nord theme (consistent with Nushell and Zsh)
# Must load after oh-my-bash to properly override the prompt

# Initialize starship for interactive shells (starship is assumed to be installed)
if [[ $- == *i* ]] && [[ "${TERM:-}" != "dumb" ]]; then
    if command -v starship &> /dev/null; then
        # Save any existing PROMPT_COMMAND (e.g., from mise)
        _starship_existing_prompt_command="$PROMPT_COMMAND"
        
        # Clear PS1 to ensure starship can set it properly
        # oh-my-bash may have set PS1 even with empty theme
        PS1=""
        
        # Initialize Starship for Bash
        # This must run after oh-my-bash to override its prompt
        eval "$(starship init bash)"
        
        # starship init bash may have saved the existing PROMPT_COMMAND in STARSHIP_PROMPT_COMMAND
        # or set PROMPT_COMMAND to just "starship_precmd"
        # We need to ensure both mise's hook and starship run together
        if [[ -n "$_starship_existing_prompt_command" ]]; then
            # If starship saved it in STARSHIP_PROMPT_COMMAND, use that
            if [[ -n "${STARSHIP_PROMPT_COMMAND:-}" ]]; then
                # starship already preserved it, but we want mise's hook to run first
                export PROMPT_COMMAND="$_starship_existing_prompt_command; starship_precmd"
            elif [[ "$PROMPT_COMMAND" == "starship_precmd" ]]; then
                # starship replaced it, restore mise's hook
                export PROMPT_COMMAND="$_starship_existing_prompt_command; starship_precmd"
            fi
        fi
        
        # Ensure PROMPT_COMMAND is exported so it persists
        export PROMPT_COMMAND
        
        # Add right prompt support for bash (bash doesn't natively support right prompts)
        # We'll append it to PROMPT_COMMAND to run after starship_precmd
        if [[ -z "${BLE_ATTACHED:-}" ]]; then
            _starship_add_right_prompt() {
                local right_prompt=$(starship prompt --right 2>/dev/null)
                if [[ -n "$right_prompt" ]]; then
                    # Get terminal width
                    local cols=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}
                    # Calculate visible length of right prompt (strip ANSI codes for measurement)
                    local right_len=$(echo -n "$right_prompt" | sed 's/\x1b\[[0-9;]*m//g' | wc -c)
                    # Calculate visible length of left prompt (strip escape sequences for measurement)
                    local left_ps1_clean=$(echo -n "$PS1" | sed 's/\\\[//g; s/\\\]//g; s/\x1b\[[0-9;]*m//g')
                    local left_len=$(echo -n "$left_ps1_clean" | wc -c)
                    
                    # Right-align the right prompt using absolute cursor positioning:
                    # After PS1 prints the left prompt, cursor is at position (left_len + 1)
                    # We need to: save cursor, move to right edge, back up by right_len, print, restore cursor
                    # Use \[ \] to mark non-printing escape sequences for bash
                    # \033[s = save cursor, \033[u = restore cursor
                    # \033[NG = move to column N (absolute, 1-indexed)
                    # Move to last column, then back up by right_len to start printing
                    PS1="${PS1}\[\033[s\033[${cols}G\033[${right_len}D\]${right_prompt}\[\033[u\033[0m\]"
                fi
            }
            
            # Add right prompt function to PROMPT_COMMAND after starship_precmd
            if [[ "$PROMPT_COMMAND" == *"starship_precmd"* ]]; then
                export PROMPT_COMMAND="${PROMPT_COMMAND}; _starship_add_right_prompt"
            fi
        fi
        
        # Trigger starship_precmd once to set the initial prompt
        # This ensures PS1 is set immediately, not just on the next command
        if type starship_precmd &> /dev/null; then
            starship_precmd
            # Add right prompt if function exists
            if type _starship_add_right_prompt &> /dev/null 2>&1; then
                _starship_add_right_prompt
            fi
            # Force PS1 to be set by starship (in case something reset it)
            export PS1
        fi
        
        # Clean up temporary variable
        unset _starship_existing_prompt_command
        
        # Set starship shell identifier
        export STARSHIP_SHELL="bash"
    fi
fi
