#!/bin/bash

wget http://zhengkai.github.io/authorized_keys -O /tmp/authorized_keys
cp /tmp/authorized_keys ~/.ssh/authorized_keys
chmod 644 ~/.ssh/authorized_keys

wget https://raw.githubusercontent.com/zhengkai/config/master/file/sudoers_nopassword -O /tmp/sudoers_nopassword
sudo cp /tmp/sudoers_nopassword /etc/sudoers.d/nopassword

if [ "$USER" == 'root' ]; then

	adduser --disabled-password --gecos "" zhengkai

	adduser zhengkai sudo

	mkdir -p /home/zhengkai/.ssh
	cp ~/.ssh/authorized_keys /home/zhengkai/.ssh/authorized_keys

	chown -R zhengkai:zhengkai /home/zhengkai

	exit
fi

sudo apt install -y vim git wget rng-tools

mkdir -p ~/.ssh

sudo chown -R zhengkai:zhengkai ~/

git clone https://github.com/zhengkai/config.git ~/conf

~/conf/script/update-ubuntu.sh

~/conf/apt/aptget.sh

sudo chsh -s /bin/zsh zhengkai

git clone https://github.com/zhengkai/build.git ~/build
~/build/rc-local/install.sh

sudo cp ~/build/shadowsocks/20-shadowsocks.conf /etc/sysctl.d/

~/conf/link.sh

~/build/bbr/run.sh || :

git clone https://github.com/zhengkai/vimrc.git ~/.vim
mkdir -p ~/.tmp/vim-undo
cd ~/.vim
git submodule update --init --recursive

touch ~/.tmp/yankring_history_v2.txt

sudo chown -R zhengkai:zhengkai ~/

vim +PlugInstall +qall || :
