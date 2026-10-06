#!/bin/zsh
set -e

DOT="$(cd "$(dirname "$0")" && pwd)"
IS_MAC=$([[ $(uname) == "Darwin" ]] && echo true || echo false)

echo "Setting up dotfiles from $DOT"

# Initialize git submodules (zsh plugins)
echo "Initializing submodules..."
cd "$DOT"
git submodule update --init --recursive

# Create config directory
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"

# Symlink configs (cross-platform)
echo "Symlinking configs..."
ln -sf "$DOT/zsh/zshrc" "$HOME/.zshrc"
ln -sf "$DOT/zsh/p10k" "$HOME/.p10k.zsh"
ln -sf "$DOT/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$DOT/ghostty" "$HOME/.config/ghostty"
ln -sfn "$DOT/nvim" "$HOME/.config/nvim"
ln -sfn "$DOT/gh" "$HOME/.config/gh"

# Linux-only configs
if ! $IS_MAC; then
    ln -sfn "$DOT/rofi" "$HOME/.config/rofi"
    ln -sfn "$DOT/sway" "$HOME/.config/sway"
    ln -sfn "$DOT/waybar" "$HOME/.config/waybar"
    ln -sfn "$DOT/mako" "$HOME/.config/mako"
    ln -sf "$DOT/zsh/zprofile" "$HOME/.zprofile"

    # login screen (greetd); its config lives here too
    if [ -d /etc/greetd ]; then
        echo "Linking greetd config (needs sudo)..."
        for f in config.toml environments gtkgreet.css; do
            sudo ln -sf "$DOT/greetd/$f" "/etc/greetd/$f"
        done
        sudo ln -sf "$DOT/scripts/sway-session" /usr/local/bin/sway-session
    fi
fi

# Symlink scripts
echo "Symlinking scripts..."
for script in "$DOT"/scripts/*; do
    ln -sf "$script" "$HOME/.local/bin/$(basename "$script")"
done

# Claude Code hooks (referenced by absolute path from ~/.claude/settings.json)
echo "Symlinking Claude hooks..."
mkdir -p "$HOME/.claude/hooks"
for hook in "$DOT"/claude/hooks/*; do
    ln -sf "$hook" "$HOME/.claude/hooks/$(basename "$hook")"
done

# The hooks above do nothing until settings.json invokes them. settings.json is
# untracked (machine-specific + private), so merge the entries instead.
python3 "$DOT/claude/register-hooks.py" || echo "Warning: could not register Claude hooks"

# tmux plugin manager, required by the @plugin lines in tmux/tmux.conf
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "Installing tmux plugin manager..."
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
if command -v tmux >/dev/null 2>&1; then
    echo "Installing tmux plugins..."
    "$TPM_DIR/bin/install_plugins" || echo "Warning: tmux plugin install failed"
fi

# Install JetBrainsMono Nerd Font
if $IS_MAC; then
    FONT_DIR="$HOME/Library/Fonts"
else
    FONT_DIR="$HOME/.local/share/fonts"
fi
mkdir -p "$FONT_DIR"

if ! find "$FONT_DIR" -name "*JetBrainsMono*Nerd*" 2>/dev/null | grep -q .; then
    echo "Installing JetBrainsMono Nerd Font..."
    tmp=$(mktemp -d)
    curl -sL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz -o "$tmp/JetBrainsMono.tar.xz"
    tar xf "$tmp/JetBrainsMono.tar.xz" -C "$FONT_DIR/"
    rm -rf "$tmp"
    if ! $IS_MAC; then
        fc-cache -f
    fi
else
    echo "JetBrainsMono Nerd Font already installed"
fi

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi

source "$HOME/.zshrc"

echo "Done!"
