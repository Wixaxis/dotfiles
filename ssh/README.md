# SSH Configuration Setup

## Overview

This package contains SSH configuration and setup scripts for connecting to the homelab server via SSH keys instead of passwords.

## Quick Setup (Automated)

Use the setup script for an interactive setup:

```bash
cd ~/dotfiles/ssh
./scripts/setup-ssh-keys.sh
```

This script will:
- Set up SSH config to include dotfiles configuration (adds Include directive)
- Check if you have an SSH key, generate one if needed
- Copy your public key to the server(s)
- Test the connection
- Guide you through the process

## Manual Setup Instructions

### Step 1: Generate SSH Key (Client - This PC)

If you don't have an SSH key yet, generate one:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_ed25519
```

**Important:**
- Press Enter to accept default location (`~/.ssh/id_ed25519`)
- **Set a passphrase** for security (or press Enter twice for no passphrase - less secure)
- The passphrase protects your private key if someone gains access to your computer

### Step 2: Copy Public Key to Server

You have two options depending on which connection method works:

#### Option A: Via Cloudflare Tunnel (if password auth works)

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub wixaxis@ssh.wixaxis.dev
```

Or manually:
```bash
cat ~/.ssh/id_ed25519.pub | ssh wixaxis@ssh.wixaxis.dev "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

#### Option B: Via Local Network (if password auth works)

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub wixaxis@hp-mini-ubuntu-server
```

Or manually:
```bash
cat ~/.ssh/id_ed25519.pub | ssh wixaxis@hp-mini-ubuntu-server "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

**Note:** You'll need to enter your password one last time during this step.

### Step 3: Verify Server Configuration

After copying the key, verify the server has correct permissions:

```bash
# Connect to server (you'll still need password this time)
ssh wixaxis@ssh.wixaxis.dev

# On the server, check permissions:
ls -la ~/.ssh/
# Should show:
# drwx------  .ssh
# -rw-------  authorized_keys

# If permissions are wrong, fix them:
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### Step 4: Test Connection

Try connecting without password:

```bash
# Via Cloudflare Tunnel
ssh homelab

# Via Local Network
ssh homelab-local
```

You should **not** be prompted for a password. If you set a passphrase on your key, you'll be asked for that instead (which is stored in your keychain on macOS).

### Step 5: Set Up SSH Config Include

The dotfiles SSH configuration is kept separate from your local SSH config. The setup script automatically adds an `Include` directive to your `~/.ssh/config` file.

**How it works:**
- Dotfiles config source is in `~/dotfiles/ssh/.ssh/dotfiles.conf`
- When stowed, it creates `~/.ssh/dotfiles.conf` (symlink to dotfiles)
- Your local `~/.ssh/config` includes it via: `Include ~/.ssh/dotfiles.conf`
- You can add your own local SSH config entries to `~/.ssh/config` without affecting dotfiles
- The setup script automatically adds the Include line if it's not already present

**Manual setup (if needed):**

If you want to manually add the Include directive, add this line at the top of your `~/.ssh/config`:

```ssh-config
Include ~/.ssh/dotfiles.conf
```

**Stowing the package:**

First, stow the ssh package to make the dotfiles config available:

```bash
cd ~/dotfiles
stow ssh
```

Then run the setup script (which will add the Include directive automatically):

```bash
cd ~/dotfiles/ssh
./scripts/setup-ssh-keys.sh
```

**The dotfiles config includes:**
- `IdentityFile ~/.ssh/id_ed25519` - specifies which key to use
- `PreferredAuthentications publickey` - forces key-based auth
- `IdentitiesOnly yes` - prevents trying other keys
- Host configurations for `homelab` and `homelab-local`

## Troubleshooting

### "Permission denied (publickey)"

1. **Check key is copied correctly:**
   ```bash
   ssh wixaxis@ssh.wixaxis.dev "cat ~/.ssh/authorized_keys"
   ```
   Should show your public key.

2. **Check server permissions:**
   ```bash
   ssh wixaxis@ssh.wixaxis.dev "ls -la ~/.ssh/"
   ```
   `.ssh` should be `700` and `authorized_keys` should be `600`.

3. **Check SSH daemon config on server:**
   ```bash
   ssh wixaxis@ssh.wixaxis.dev "sudo grep -E 'PubkeyAuthentication|AuthorizedKeysFile' /etc/ssh/sshd_config"
   ```
   Should show:
   ```
   PubkeyAuthentication yes
   AuthorizedKeysFile .ssh/authorized_keys
   ```

### "Too many authentication failures"

Add this to your SSH config:
```ssh-config
IdentitiesOnly yes
```

### macOS Keychain Integration

On macOS, you can store your SSH key passphrase in the keychain:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

This is already handled in the `qa()` function in zsh config.

## Using with Kamal

Once SSH keys are set up, Kamal will automatically use them for deployments. No additional configuration needed - Kamal uses SSH under the hood.

## Server-Side Setup (mini-pc)

After copying your public key, verify the server configuration:

### 1. Check SSH Daemon Configuration

On the server (mini-pc), verify SSH is configured to accept public keys:

```bash
# Connect to server (you'll need password this time)
ssh wixaxis@ssh.wixaxis.dev

# Check SSH daemon config
sudo grep -E 'PubkeyAuthentication|AuthorizedKeysFile|PasswordAuthentication' /etc/ssh/sshd_config
```

Should show:
```
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
# PasswordAuthentication yes  (can be yes or no, depending on your preference)
```

If `PubkeyAuthentication` is `no`, enable it:
```bash
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/PubkeyAuthentication no/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

### 2. Verify Key Permissions

On the server, check that permissions are correct:

```bash
ls -la ~/.ssh/
```

Should show:
```
drwx------  .ssh
-rw-------  authorized_keys
```

If permissions are wrong, fix them:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### 3. Verify Your Public Key is Present

```bash
cat ~/.ssh/authorized_keys
```

Should contain your public key (the one from `~/.ssh/id_ed25519.pub` on your client).

### 4. Test from Server Side

You can test that the key is working by trying to connect from the client. If it still asks for a password, check:

1. **SSH daemon logs:**
   ```bash
   sudo journalctl -u sshd -n 50 --no-pager
   ```
   Look for authentication errors.

2. **SELinux (if enabled):**
   ```bash
   sudo getenforce
   ```
   If it shows "Enforcing", you may need to:
   ```bash
   sudo restorecon -R ~/.ssh
   ```

3. **File ownership:**
   ```bash
   ls -la ~/.ssh/
   ```
   Files should be owned by `wixaxis`, not `root`.

## Security Notes

- **Never share your private key** (`~/.ssh/id_ed25519`) - keep it secret!
- The **public key** (`~/.ssh/id_ed25519.pub`) is safe to share - it's meant to be copied to servers
- Use a passphrase on your private key for extra security
- Consider using `ssh-agent` or keychain to avoid typing passphrase repeatedly
- On the server, you can disable password authentication after confirming key-based auth works:
  ```bash
  sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
  sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
  sudo systemctl restart sshd
  ```
  **Warning:** Only do this after confirming key-based auth works, or you might lock yourself out!
