#!/bin/bash

chown_home() {
	sudo chown -R "${USER}:${USER}" "$HOME"
}

SSH_AUTH="${HOME}/.ssh/authorized_keys"
mkdir -p "${HOME}/.ssh"
touch "$SSH_AUTH"
chmod 644 "$SSH_AUTH"
if ! grep -q 'zhengkai@Freya' "$SSH_AUTH"
then
	curl -s --fail https://zhengkai.github.io/authorized_keys -o /tmp/authorized_keys || ( >&2 echo get authorized_keys fail && exit 1)
	cat /tmp/authorized_keys >> "$SSH_AUTH"
fi

if [ ! -e "/etc/sudoers.d/nopassword" ]; then
	echo '%sudo   ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/nopassword
fi

if [ "$USER" != 'zhengkai' ]; then

	sudo adduser --disabled-password --gecos "" zhengkai

	sudo adduser zhengkai sudo

	sudo mkdir -p /home/zhengkai/.ssh
	sudo cp ~/.ssh/authorized_keys /home/zhengkai/.ssh/authorized_keys

	sudo chown -R zhengkai:zhengkai /home/zhengkai

	exit
fi

if ! id | grep -q '(sudo)'
then
	>&2 echo no sudo
	exit 1
fi

sudo apt install -y vim git wget rng-tools

chown_home

git clone --depth 1 https://github.com/zhengkai/conf.git ~/conf

~/conf/update/ubuntu.sh

~/conf/apt/aptget.sh

sudo chsh -s /bin/zsh zhengkai

git clone --depth 1 https://github.com/zhengkai/build.git ~/build
~/build/rc-local/install.sh

sudo cp ~/build/shadowsocks/20-shadowsocks.conf /etc/sysctl.d/

~/conf/link.sh

~/build/bbr/run.sh || :

git clone --depth 1 https://github.com/zhengkai/vimrc.git ~/.vim
mkdir -p ~/.tmp/vim-undo
cd ~/.vim && git submodule update --init --recursive

touch ~/.tmp/yankring_history_v2.txt

chown_home

vim -E +PlugInstall +qall >/dev/null || :
