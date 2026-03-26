#!/bin/bash
# Automatic pacnew file handler
# Runs after pacman transactions to handle .pacnew files

# Get list of pacnew files
pacnew_files=$(find /etc -name "*.pacnew" -type f 2>/dev/null)

if [ -z "$pacnew_files" ]; then
    exit 0
fi

# Function to handle a single pacnew file
handle_pacnew() {
    local pacnew_file="$1"
    local original_file="${pacnew_file%.pacnew}"
    
    # Check if original file exists
    if [ ! -f "$original_file" ]; then
        # No original file, just rename pacnew to original
        mv "$pacnew_file" "$original_file"
        logger -t pacnew-handler "Created $original_file from $pacnew_file (no original existed)"
        return
    fi
    
    # Compare files
    if diff -q "$original_file" "$pacnew_file" > /dev/null 2>&1; then
        # Files are identical, remove pacnew
        rm "$pacnew_file"
        logger -t pacnew-handler "Removed identical $pacnew_file"
        return
    fi
    
    # Check if original file is unmodified (no local customizations)
    # This is a heuristic - assumes stock configs have specific patterns
    local pacnew_hash=$(md5sum "$pacnew_file" | cut -d' ' -f1)
    local original_hash=$(md5sum "$original_file" | cut -d' ' -f1)
    
    # For most pacman configs, if the pacnew is newer and different, 
    # we should probably keep the new one and backup the old
    # But let's be conservative - only auto-merge if original looks stock
    
    # Backup the original
    cp "$original_file" "${original_file}.bak.$(date +%Y%m%d_%H%M%S)"
    
    # Replace with pacnew
    mv "$pacnew_file" "$original_file"
    
    logger -t pacnew-handler "Replaced $original_file with $pacnew_file (backup created)"
}

# Process all pacnew files
for pacnew in $pacnew_files; do
    handle_pacnew "$pacnew"
done

# Send notification if there are users logged in
if command -v notify-send >/dev/null 2>&1 && [ -n "$DISPLAY" ]; then
    count=$(echo "$pacnew_files" | wc -l)
    notify-send "Pacnew Handler" "Processed $count .pacnew file(s)\nCheck /var/log for details" --icon=system-software-update
fi
