#!/bin/bash

ACCOUNT="zhengkai"

chown_home() {
	sudo chown -R "${USER}:${USER}" "$HOME"
}

if ! id | grep -q '(sudo)'; then
	>&2 echo no sudo
	exit 1
fi

SSH_AUTH="${HOME}/.ssh/authorized_keys"
mkdir -p "${HOME}/.ssh"
touch "$SSH_AUTH"
chmod 644 "$SSH_AUTH"
if ! grep -q 'zhengkai@Anna' "$SSH_AUTH"; then
	curl -s --fail https://zhengkai.github.io/authorized_keys -o /tmp/authorized_keys || ( >&2 echo get authorized_keys fail && exit 1)
	cat /tmp/authorized_keys >> "$SSH_AUTH"
fi

if [ ! -e "/etc/sudoers.d/nopassword" ]; then
	echo '%sudo   ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/nopassword
fi

if [ "$USER" != "$ACCOUNT" ]; then

	sudo adduser --disabled-password --gecos "" "$ACCOUNT"

	sudo adduser "$ACCOUNT" sudo

	sudo mkdir -p "/home/${ACCOUNT}/.ssh"
	sudo cp ~/.ssh/authorized_keys "/home/${ACCOUNT}/.ssh/authorized_keys"

	sudo chown -R "${ACCOUNT}:${ACCOUNT}" "/home/${ACCOUNT}"

	exit
fi

sudo apt install -y vim git wget rng-tools net-tools

chown_home

if [ ! -e ~/conf ]; then
	git clone --depth 1 "https://github.com/zhengkai/conf.git" ~/conf || exit 1
fi

mkdir -p ~/.config
if [ ! -f ~/.config/env ]; then
	cp ~/conf/misc/env ~/.config/env
fi

~/conf/update/ubuntu.sh

~/conf/apt/aptget.sh || exit 1

if [ -x /bin/zsh ]; then
	sudo chsh -s /bin/zsh "$ACCOUNT"
fi

if [ ! -e ~/build ]; then
	git clone --depth 1 "https://github.com/zhengkai/build.git" ~/build
fi
~/build/rc-local/install.sh
~/build/tty/autologin.sh

sudo cp ~/build/shadowsocks/20-shadowsocks.conf /etc/sysctl.d/

~/conf/link.sh

~/build/bbr/run.sh || :

if [ ! -e ~/.vim ]; then
	git clone --depth 1 "https://github.com/zhengkai/vimrc.git" ~/.vim
fi
cd ~/.vim && git submodule update --init --recursive

chown_home
