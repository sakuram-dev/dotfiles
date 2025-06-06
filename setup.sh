#!/bin/bash

# This script sets up a new Ubuntu system with my preferred packages and dotfiles

# Exit script on any error
set -e

# Define a list of packages to install
PACKAGES=(
    "zsh"
    "tmux"
    "vim"
    # add more packages as needed
)

# Check if the DISPLAY environment variable is set
if [ -n "$DISPLAY" ]; then
    echo "DISPLAY environment variable is set, adding GUI packages..."
    PACKAGES+=(
        "ulauncher"
        # add more GUI packages as needed
    )
    # Add necessary repositories for ulauncher
    sudo add-apt-repository universe -y
    sudo add-apt-repository ppa:agornostal/ulauncher -y
else
    echo "DISPLAY environment variable is not set, skipping GUI packages..."
fi

# Update and install necessary packages
if ! sudo apt update; then
    echo "Failed to update packages, exiting..."
    exit 1
fi

# Install packages
for package in "${PACKAGES[@]}"; do
    if dpkg -s "$package" >/dev/null 2>&1; then
        echo "$package is already installed, skipping..."
    else
        if ! sudo apt install -y "$package"; then
            echo "Failed to install $package, exiting..."
            exit 1
        fi
    fi
done

# Get thedirectory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Automatically detect dotfiles to symlink
DOT_FILES=($(find $SCRIPT_DIR -maxdepth 1 -type f -name ".*" -exec basename {} \;))

# Create symlinks for each dotfile, overwrite if exists
for file in "${DOT_FILES[@]}"; do
    if ! ln -sf "$SCRIPT_DIR/$file" "$HOME/$file"; then
        echo "Failed to create symlink for $file, exiting..."
        exit 1
    fi
done

# Ensure .config directory exists
mkdir -p $HOME/.config

# Create symlinks for each item in .config, overwrite if exists
for item in $(find $SCRIPT_DIR/.config -mindepth 1 -maxdepth 1); do
    if ! ln -sf $item $HOME/.config/; then
        echo "Failed to create symlink for $(basename $item), exiting..."
        exit 1
    fi
done

# create a local config directory if it doesn't exist
mkdir -p $SCRIPT_DIR/local
# create a local config file if it doesn't exist
if [ ! -f "$SCRIPT_DIR/local/.zsh_local" ]; then
    touch $SCRIPT_DIR/local/.zsh_local
    echo "Created $SCRIPT_DIR/local/.zsh_local"
else
    echo "$SCRIPT_DIR/local/.zsh_local already exists"
fi

# Install Starship prompt
if ! command -v starship &> /dev/null; then
    echo "Starship prompt not found, installing..."
    curl -sS https://starship.rs/install.sh | sh
else
    echo "Starship prompt is already installed."
fi

# Change default shell to zsh and start zsh
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "Changing default shell to zsh..."
    chsh -s /usr/bin/zsh
    echo "Starting zsh..."
    exec /usr/bin/zsh
else
    echo "zsh is already the default shell. Starting zsh..."
    exec /usr/bin/zsh
fi