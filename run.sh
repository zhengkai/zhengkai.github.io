#!/bin/bash

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

if [ "$USER" != 'zhengkai' ]; then

	sudo adduser --disabled-password --gecos "" zhengkai

	sudo adduser zhengkai sudo

	sudo mkdir -p /home/zhengkai/.ssh
	sudo cp ~/.ssh/authorized_keys /home/zhengkai/.ssh/authorized_keys

	sudo chown -R zhengkai:zhengkai /home/zhengkai

	exit
fi

sudo apt install -y vim git wget rng-tools net-tools

chown_home

git clone --depth 1 https://github.com/zhengkai/conf.git ~/conf || exit 1

~/conf/update/ubuntu.sh

~/conf/apt/aptget.sh || exit 1

if [ -x /bin/zsh ]; then
	sudo chsh -s /bin/zsh zhengkai
fi

git clone --depth 1 https://github.com/zhengkai/build.git ~/build
~/build/rc-local/install.sh

sudo cp ~/build/shadowsocks/20-shadowsocks.conf /etc/sysctl.d/

~/conf/link.sh

~/build/bbr/run.sh || :

git clone --depth 1 https://github.com/zhengkai/vimrc.git ~/.vim
cd ~/.vim && git submodule update --init --recursive

chown_home

vim -E +PlugInstall +qall >/dev/null || :
