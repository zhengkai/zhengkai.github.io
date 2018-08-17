#!/bin/bash

wget http://zhengkai.github.io/authorized_keys -O /tmp/authorized_keys
cp /tmp/authorized_keys ~/.ssh/authorized_keys
chmod 644 ~/.ssh/authorized_keys

if [ "$USER" == 'root' ]; then

	apt install pwgen

	PASSWD=`pwgen 12 1`
	echo $PASSWD > ~/pwd.txt
	chmod 600 ~/pwd.txt

	adduser --disabled-password --gecos "" zhengkai
	echo -e "$PASSWD\n$PASSWD" | passwd zhengkai

	adduser zhengkai sudo

	mkdir -p /home/zhengkai/.ssh
	cp ~/.ssh/authorized_keys /home/zhengkai/.ssh/authorized_keys

	chown -R zhengkai:zhengkai /home/zhengkai

	exit
fi

sudo apt install -y vim git wget

mkdir -p ~/.ssh

sudo chown -R zhengkai:zhengkai ~/

git clone https://github.com/zhengkai/config.git ~/conf

~/conf/script/update-ubuntu.sh

~/conf/apt/aptget.sh

~/conf/link.sh

git clone https://github.com/zhengkai/vimrc.git ~/.vim
mkdir -p ~/.tmp/vim-undo
cd ~/.vim
git submodule update --init --recursive
vim +PlugInstall +qall

sudo chsh -s /bin/zsh zhengkai

git clone https://github.com/zhengkai/build.git ~/build
~/build/rc-local/install.sh

sudo cp ~/build/shadowsocks/20-shadowsocks.conf /etc/sysctl.d/
