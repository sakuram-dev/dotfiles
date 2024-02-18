#!/bin/bash

# for ulauncher
sudo add-apt-repository universe -y && sudo add-apt-repository ppa:agornostal/ulauncher -y

# install 
sudo apt update
sudo apt install tmux vim ulauncher -y

DOT_FILES=(.tmux.conf .vimrc)

for file in ${DOT_FILES[@]}
do
	ln -s $HOME/dotfiles/$file $HOME/$file
done

# .config
mkdir -p $HOME/.config
for item in $(find $HOME/dotfiles/.config -mindepth 1 -maxdepth 1)
do
    ln -s $item $HOME/.config/
done
