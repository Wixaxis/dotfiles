#!/usr/bin/env bash
# SSH Key Setup Script
# Helps copy SSH public key to homelab server
# Idempotent - safe to run multiple times

set -eo pipefail

# ============================================================================
# GUM CHECK
# ============================================================================
check_gum() {
    if ! command -v gum &> /dev/null; then
        echo "⚠️  gum is not installed. Please install it first:"
        echo "  - Arch: paru -S gum"
        echo "  - macOS: brew install gum"
        exit 1
    fi
}

check_gum

# ============================================================================
# PRINT FUNCTIONS (using gum)
# ============================================================================
info() { gum style --foreground 12 "ℹ" "$1"; }
success() { gum style --foreground 10 "✓" "$1"; }
warning() { gum style --foreground 11 "⚠" "$1"; }
error() { gum style --foreground 9 "✗" "$1"; }
section() { 
    echo ""
    gum style --bold --foreground 12 "━━━ $1 ━━━"
}

# ============================================================================
# CONFIGURATION
# ============================================================================
KEY_TYPE="${SSH_KEY_TYPE:-ed25519}"
KEY_FILE="$HOME/.ssh/id_${KEY_TYPE}"
PUB_KEY_FILE="${KEY_FILE}.pub"

# Server configurations
declare -A SERVERS=(
    ["homelab"]="wixaxis@ssh.wixaxis.dev"
    ["homelab-local"]="wixaxis@hp-mini-ubuntu-server"
)

declare -A SERVER_NAMES=(
    ["homelab"]="Cloudflare Tunnel"
    ["homelab-local"]="Local Network"
)

# ============================================================================
# KEY MANAGEMENT
# ============================================================================
check_key_exists() {
    if [[ ! -f "$KEY_FILE" ]]; then
        warning "SSH key not found at $KEY_FILE"
        if gum confirm "Would you like to generate one?"; then
            generate_key
        else
            error "Cannot proceed without SSH key"
            exit 1
        fi
    else
        # Verify the key is valid
        if ssh-keygen -l -f "$KEY_FILE" &>/dev/null; then
            success "SSH key found: $KEY_FILE"
            local fingerprint
            fingerprint=$(ssh-keygen -l -f "$KEY_FILE" | awk '{print $2}')
            info "Fingerprint: $fingerprint"
        else
            error "Invalid or corrupted SSH key found at $KEY_FILE"
            if gum confirm "Would you like to delete it and generate a new one?"; then
                rm -f "$KEY_FILE" "${KEY_FILE}.pub"
                generate_key
            else
                error "Cannot proceed with invalid key"
                exit 1
            fi
        fi
    fi
}

generate_key() {
    section "Generating SSH Key"
    
    info "You'll be prompted for:"
    echo "  • Location (press Enter for default: $KEY_FILE)"
    echo "  • Passphrase (recommended for security)"
    echo ""
    
    # Get hostname safely with fallback
    local hostname_val
    hostname_val=$(uname -n 2>/dev/null || echo "unknown")
    local hostname_comment
    hostname_comment="$(whoami)@${hostname_val}"
    
    if ssh-keygen -t "$KEY_TYPE" -C "$hostname_comment" -f "$KEY_FILE"; then
        success "SSH key generated successfully"
        local fingerprint
        fingerprint=$(ssh-keygen -l -f "$KEY_FILE" | awk '{print $2}')
        info "Fingerprint: $fingerprint"
    else
        error "Failed to generate SSH key"
        exit 1
    fi
}

show_public_key() {
    section "Your Public Key"
    echo ""
    gum style --foreground 14 "$(cat "$PUB_KEY_FILE")"
    echo ""
    info "This key will be copied to the server"
}

# ============================================================================
# SERVER OPERATIONS
# ============================================================================
check_key_on_server() {
    local server="$1"
    local pub_key_content
    pub_key_content=$(cat "$PUB_KEY_FILE")
    
    # Check if key already exists on server (with timeout and no password prompt)
    # Use BatchMode to avoid password prompts, and timeout to avoid hanging
    if ssh -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$server" "test -f ~/.ssh/authorized_keys && grep -qF '${pub_key_content}' ~/.ssh/authorized_keys" 2>/dev/null; then
        return 0  # Key exists
    else
        return 1  # Key doesn't exist or can't check
    fi
}

copy_key_to_server() {
    local server_alias="$1"
    local server="${SERVERS[$server_alias]}"
    local server_name="${SERVER_NAMES[$server_alias]}"
    
    section "Copying Key to $server_name"
    
    info "Server: $server"
    echo ""
    warning "You'll need to enter your password for: $server"
    info "The script will add your public key to the server's authorized_keys file"
    echo ""
    
    if ! gum confirm "Ready to proceed?"; then
        info "Skipping $server_name"
        return 0
    fi
    
    echo ""
    info "Connecting to server..."
    
    # Build SSH command with appropriate options
    local ssh_cmd="ssh"
    local ssh_opts=(-o ConnectTimeout=10)
    
    # Add ProxyCommand for Cloudflare Tunnel
    if [[ "$server_alias" == "homelab" ]]; then
        if ! command -v cloudflared &> /dev/null; then
            error "cloudflared is required for Cloudflare Tunnel connection"
            error "Please install it: paru -S cloudflared (or brew install cloudflared)"
            return 1
        fi
        ssh_opts+=(-o "ProxyCommand=cloudflared access ssh --hostname %h")
        info "Using Cloudflare Tunnel proxy..."
    fi
    
    ssh_opts+=("$server")
    
    # Copy the key (avoid duplicates)
    local pub_key_content
    pub_key_content=$(cat "$PUB_KEY_FILE")
    
    echo ""
    warning "You will be prompted for your password now"
    info "Enter your password when you see the SSH prompt below:"
    echo ""
    
    # Execute SSH command directly - don't capture output so password prompt is visible
    # Use a temporary script file to avoid quoting issues
    local temp_script
    temp_script=$(mktemp)
    cat > "$temp_script" << 'EOFSCRIPT'
mkdir -p ~/.ssh 2>/dev/null || true
chmod 700 ~/.ssh
if ! grep -qF 'PUBKEY_PLACEHOLDER' ~/.ssh/authorized_keys 2>/dev/null; then
    echo 'PUBKEY_PLACEHOLDER' >> ~/.ssh/authorized_keys
    echo 'KEY_ADDED'
else
    echo 'KEY_EXISTS'
fi
chmod 600 ~/.ssh/authorized_keys
echo 'SUCCESS'
EOFSCRIPT
    
    # Replace placeholder with actual key
    sed -i "s|PUBKEY_PLACEHOLDER|${pub_key_content}|g" "$temp_script"
    
    # Build SSH command with appropriate options BEFORE executing
    local ssh_opts=(-o ConnectTimeout=10)
    
    # Add ProxyCommand for Cloudflare Tunnel
    if [[ "$server_alias" == "homelab" ]]; then
        if ! command -v cloudflared &> /dev/null; then
            error "cloudflared is required for Cloudflare Tunnel connection"
            error "Please install it: paru -S cloudflared (or brew install cloudflared)"
            rm -f "$temp_script"
            return 1
        fi
        ssh_opts+=(-o "ProxyCommand=cloudflared access ssh --hostname %h")
        info "Using Cloudflare Tunnel proxy..."
    fi
    
    ssh_opts+=("$server")
    
    # Execute SSH - output goes directly to terminal so password prompt is visible
    info "Connecting to $server..."
    echo ""
    warning "You will be prompted for your password now"
    echo ""
    
    # Execute SSH directly without capturing output - password prompt will be visible
    local ssh_exit_code=0
    ssh "${ssh_opts[@]}" "bash" < "$temp_script" || ssh_exit_code=$?
    
    rm -f "$temp_script"
    
    echo ""
    
    # Check if it worked (we can't check output since we didn't capture it)
    if [[ $ssh_exit_code -eq 0 ]]; then
        success "SSH command completed successfully"
        info "Key should now be added to $server_name"
        info "You can test the connection with: ssh $server_alias"
        return 0
    else
        error "Failed to copy key to $server_name"
        echo ""
        error "SSH exit code: $ssh_exit_code"
        echo ""
        error "Possible issues:"
        echo "  • Server is not reachable"
        echo "  • Password authentication is disabled"
        echo "  • Incorrect credentials"
        echo "  • Network connectivity problems"
        echo ""
        return 1
    fi
}

test_connection() {
    local host_alias="$1"
    local server_name="${SERVER_NAMES[$host_alias]}"
    
    section "Testing Connection to $server_name"
    
    info "Testing SSH connection (this should not prompt for password)..."
    
    # Try to connect with verbose output for debugging
    local test_output
    test_output=$(ssh -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$host_alias" "echo 'SUCCESS'" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        success "Connection test successful - no password required!"
        info "You can now use: ssh $host_alias"
        return 0
    else
        warning "Connection test failed"
        echo ""
        info "Possible reasons:"
        echo "  • Key was just added - SSH may need a moment to recognize it"
        echo "  • Server permissions may be incorrect"
        echo "  • SSH daemon may need to be restarted on server"
        echo ""
        info "Exit code: $exit_code"
        if [[ -n "$test_output" ]]; then
            info "SSH output:"
            echo "$test_output" | sed 's/^/  /'
        fi
        echo ""
        if gum confirm "Would you like to try connecting manually to test?"; then
            info "Run this command to test manually:"
            echo "  ssh $host_alias"
            echo ""
            gum confirm "Press Enter when ready to continue..." && true
        fi
        return 1
    fi
}

verify_server_setup() {
    local server_alias="$1"
    local server="${SERVERS[$server_alias]}"
    local server_name="${SERVER_NAMES[$server_alias]}"
    
    section "Verifying Server Setup for $server_name"
    
    info "Checking server configuration..."
    
    # Check permissions
    local perms_check
    perms_check=$(ssh "$server" "ls -ld ~/.ssh && ls -l ~/.ssh/authorized_keys 2>/dev/null" 2>/dev/null || echo "ERROR")
    
    if echo "$perms_check" | grep -q "ERROR"; then
        warning "Could not check server permissions (this is okay if key auth works)"
    else
        info "Server permissions:"
        echo "$perms_check" | sed 's/^/  /'
    fi
    
    # Check if our key is there
    if check_key_on_server "$server" 2>/dev/null; then
        success "Your public key is present in ~/.ssh/authorized_keys"
    else
        warning "Could not verify key presence (may still work)"
    fi
}

# ============================================================================
# SSH CONFIG INCLUDE SETUP
# ============================================================================
setup_ssh_config_include() {
    section "Setting up SSH config include"
    
    local ssh_config="$HOME/.ssh/config"
    local dotfiles_config="$HOME/.ssh/dotfiles.conf"
    local include_line="Include ~/.ssh/dotfiles.conf"
    
    # Ensure .ssh directory exists
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Check if dotfiles config exists (warn but continue)
    if [[ ! -f "$dotfiles_config" ]]; then
        warning "Dotfiles SSH config not found at $dotfiles_config"
        warning "Make sure you've stowed the ssh package: cd ~/dotfiles && stow ssh"
        info "Will still add Include directive - you can stow later"
    else
        success "Dotfiles SSH config found at $dotfiles_config"
    fi
    
    # Create config file if it doesn't exist
    if [[ ! -f "$ssh_config" ]]; then
        info "Creating $ssh_config"
        touch "$ssh_config"
        chmod 600 "$ssh_config"
    fi
    
    # Check if Include line already exists (check for the exact path or pattern)
    if grep -qE "Include.*\.ssh/dotfiles\.conf" "$ssh_config" 2>/dev/null || \
       grep -qF "$include_line" "$ssh_config" 2>/dev/null; then
        success "SSH config already includes dotfiles config"
        return 0
    fi
    
    # Add Include line after any existing Include directives
    info "Adding Include directive to $ssh_config"
    
    # Create a temporary file
    local temp_file
    temp_file=$(mktemp)
    
    # Track if we've inserted our include and if we're in the include section
    local inserted=false
    local in_include_section=false
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Check if this is an Include line
        if [[ "$line" =~ ^[[:space:]]*Include ]]; then
            in_include_section=true
            echo "$line" >> "$temp_file"
            continue
        fi
        
        # If we were in include section and hit a non-empty, non-include line, insert our include
        if [[ "$in_include_section" == true ]] && [[ "$inserted" == false ]] && \
           [[ ! "$line" =~ ^[[:space:]]*$ ]]; then
            echo "$include_line" >> "$temp_file"
            echo "" >> "$temp_file"
            inserted=true
            in_include_section=false
        fi
        
        # Write the line
        echo "$line" >> "$temp_file"
    done < "$ssh_config"
    
    # If we never inserted (file ended with includes or was empty), add after includes
    if [[ "$inserted" == false ]]; then
        if [[ "$in_include_section" == true ]]; then
            # File ended with includes, add ours after them
            echo "$include_line" >> "$temp_file"
        else
            # No includes found, add at the top
            local temp_file2
            temp_file2=$(mktemp)
            echo "$include_line" >> "$temp_file2"
            echo "" >> "$temp_file2"
            cat "$temp_file" >> "$temp_file2"
            mv "$temp_file2" "$temp_file"
        fi
    fi
    
    # Replace original file
    mv "$temp_file" "$ssh_config"
    chmod 600 "$ssh_config"
    
    success "Added Include directive to SSH config"
    info "Your local SSH config now includes dotfiles configuration"
    info "Include line: $include_line"
}

# ============================================================================
# MAIN MENU
# ============================================================================
main() {
    clear
    gum style --bold --foreground 14 "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    gum style --bold --foreground 14 "  SSH Key Setup for Homelab"
    gum style --bold --foreground 14 "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    setup_ssh_config_include
    echo ""
    check_key_exists
    show_public_key
    
    section "Server Selection"
    
    local choice
    choice=$(gum choose \
        "Cloudflare Tunnel (ssh.wixaxis.dev)" \
        "Local Network (hp-mini-ubuntu-server)" \
        "Both servers" \
        "Test existing connections" \
        "Verify server setup" \
        "Exit")
    
    case "$choice" in
        "Cloudflare Tunnel"*)
            if copy_key_to_server "homelab"; then
                echo ""
                test_connection "homelab"
            fi
            ;;
        "Local Network"*)
            if copy_key_to_server "homelab-local"; then
                echo ""
                test_connection "homelab-local"
            fi
            ;;
        "Both servers"*)
            if copy_key_to_server "homelab"; then
                echo ""
                test_connection "homelab"
            fi
            echo ""
            if copy_key_to_server "homelab-local"; then
                echo ""
                test_connection "homelab-local"
            fi
            ;;
        "Test existing"*)
            section "Testing Connections"
            test_connection "homelab"
            echo ""
            test_connection "homelab-local"
            ;;
        "Verify server"*)
            verify_server_setup "homelab"
            echo ""
            verify_server_setup "homelab-local"
            ;;
        "Exit"*)
            info "Exiting..."
            exit 0
            ;;
        *)
            error "Invalid choice"
            exit 1
            ;;
    esac
    
    echo ""
    section "Setup Complete"
    success "SSH key setup finished!"
    echo ""
    info "You can now connect using:"
    echo "  • ssh homelab (via Cloudflare Tunnel)"
    echo "  • ssh homelab-local (via local network)"
    echo ""
    info "For Kamal deployments, SSH keys will be used automatically."
}

main
