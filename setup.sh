#!/bin/bash

# This script sets up a new Ubuntu system with my preferred packages and dotfiles

# Exit script on any error
set -e

# Add necessary repositories for ulauncher
sudo add-apt-repository universe -y
sudo add-apt-repository ppa:agornostal/ulauncher -y

# Update and install necessary packages
if ! sudo apt update; then
    echo "Failed to update packages, exiting..."
    exit 1
fi

# Define a list of packages to install
PACKAGES=(
    "tmux"
    "vim"
    "ulauncher"
    # add more packages as needed
)

# Install packages
for package in "${PACKAGES[@]}"; do
    if dpkg -s "$package" >/dev/null 2>&1; then
        echo "$package is already installed, skipping..."
    else
        if !sudo apt install -y "$package"; then
            echo "Failed to install $package, exiting..."
            exit 1
        fi
    fi
done

# Automatically detect dotfiles to symlink
DOT_FILES=($(find $HOME/dotfiles -maxdepth 1 -type f -name ".*" -exec basename {} \;))

# Create symlinks for each dotfile, overwrite if exists
for file in "${DOT_FILES[@]}"; do
    if ! ln -sf "$HOME/dotfiles/$file" "$HOME/$file"; then
        echo "Failed to create symlink for $file, exiting..."
        exit 1
    fi
done

# Ensure .config directory exists
mkdir -p $HOME/.config

# Create symlinks for each item in .config, overwrite if exists
for item in $(find $HOME/dotfiles/.config -mindepth 1 -maxdepth 1); do
    if ! ln -sf $item $HOME/.config/; then
        echo "Failed to create symlink for $(basename $item), exiting..."
        exit 1
    fi
done
