#!/usr/bin/env bash

WARNING="\033[1;31mWARNING\033[0m: "
SUCCESS="\033[1;31mSUCCESS\033[0m: "
NOTE="\033[1;31mNOTE\033[0m: "

# XBPS PACKAGES

# List of manually installed packages
PACKAGE_LIST="./packages.txt"
if [[ -f $PACKAGE_LIST ]]; then
	sudo xbps-install -Su
	sudo xbps-install -S "$(cat "$PACKAGE_LIST")"
else
	echo -e "\n${WARNING}Missing list of XBPS packages"
	echo "  Couldn't locate $PACKAGE_LIST"
	exit 1
fi

# OTHER PACKAGES

# Pyenv
# Build requirements
xbps-install base-devel libffi-devel bzip2-devel openssl openssl-devel readline readline-devel sqlite-devel xz liblzma-devel zlib zlib-devel
git clone https://github.com/pyenv/pyenv.git "$HOME"/.pyenv
# Optional: Compile dynamic bash extension to speed up Pyenv.
cd "$HOME"/.pyenv && src/configure && make -C src

# Node & NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
# Setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install --lts
nvm use --lts

# Youtube-dl
pip install --upgrade "git+https://github.com/ytdl-org/youtube-dl.git"

# SERVICES

enable_service() {
	# Takes an arbitrary number of string arguments and enables their service
	# if they are installed.
	ORIGIN="/etc/sv"
	SERVICES="/var/service"
	for service in "${@}"; do
		if [[ -d "$ORIGIN/$service/" ]]; then
			sudo ln -s "$ORIGIN/$service/" "$SERVICES/"
		else
			echo "${WANRING}Failed to enable $service"
		fi
	done
}

disable_service() {
	# Takes an arbitrary number of string arguments and disables their service
	# if they are enabeled.
	SERVICES="/var/service"
	for service in "${@}"; do
		if [[ -d "$SERVICES/$service" ]]; then
			sudo rm "$SERVICES/$service"
		fi
	done
}

# UTILITY SERVICES

# Dbus
enable_service "dbus"

# Udev
enable_service "udevd"

# NetworkManager
disable_service "dhcpcd" "wpa_supplicant" "wicd"
enable_service "NetworkManager"

# acpid
enable_service "acpid"

# Alsa
enable_service "alsa"

# Bluetooth
enable_service "bluetoothd"

# Printers
enable_service "cups"

# DEV TOOL SERVICES

# Docker
enable_service "containerd" "docker"

# MINIMAL XINIT CONFIG

XINITRC="$HOME/.xinitrc"
MINIMAL_XINITRC="
#!/bin/bash
pulseaudio &
exec dbus-run-session /bin/qtile start"

if [[ -f $XINITRC ]]; then
	echo "$MINIMAL_XINITRC" >>"$XINITRC"
else
	touch "$XINITRC"
	echo "#!/usr/bin/env bash" >>"$XINITRC"
	echo "$MINIMAL_XINITRC" >>"$XINITRC"
fi

# SUCCESS MESSAGE

echo -e "\n${SUCCESS}Packages and services setup!"
echo "  You may now restart your system"

echo -e "\n${NOTE}You may want to fetch your dotfiles before rebooting!"
echo -e "${NOTE}You may want to change your default shell!"
