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
ln -sfn "$DOT/ghostty" "$HOME/.config/ghostty"
ln -sfn "$DOT/nvim" "$HOME/.config/nvim"
ln -sfn "$DOT/gh" "$HOME/.config/gh"

# Linux-only configs
if ! $IS_MAC; then
    ln -sfn "$DOT/awesome" "$HOME/.config/awesome"
    ln -sfn "$DOT/rofi" "$HOME/.config/rofi"
fi

# Symlink scripts
echo "Symlinking scripts..."
for script in "$DOT"/scripts/*; do
    ln -sf "$script" "$HOME/.local/bin/$(basename "$script")"
done

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
