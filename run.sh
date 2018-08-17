#!/bin/bash

sudo apt install -y vim git wget

mkdir -p ~/.ssh

wget http://zhengkai.github.io/authorized_keys -O ~/.ssh/authorized_keys
sudo chown -R zhengkai:zhengkai ~/

git clone https://github.com/zhengkai/config.git ~/conf

~/conf/apt/aptget.sh

~/conf/link.sh

git clone https://github.com/zhengkai/vimrc.git ~/.vim
mkdir -p ~/.tmp/vim-undo
cd ~/.vim
git submodule update --init --recursive
vim +PlugInstall +qall

sudo chsh -s /bin/zsh zhengkai
