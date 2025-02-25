#!/usr/bin/bash
set -e
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 
    exit 1
fi

apt update && DEBIAN_FRONTEND=noninteractive apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install gnupg curl laptop-detect -y
mkdir -p /etc/dconf/profile
mkdir -p /etc/dconf/db/local.d

DEBIAN_FRONTEND=noninteractive apt install gnome-core chromium- chromium-browser- epiphany-browser- gnome-www-browser- firefox- firefox-esr- gnome-software-plugin-deb- gnome-software-plugin-fwupd gnome-terminal -y

(cd /tmp && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg)
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt update

set +e
dpkg -i debuntu-meta.deb
set -e
DEBIAN_FRONTEND=noninteractive apt install -f -y

laptop-detect && {
  DEBIAN_FRONTEND=noninteractive apt install tlp tlp-rdw -y
} || {
  echo "Not a laptop, skipping tlp installation."
}

flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
snap install snapd

dpkg -i /usr/share/debuntu/ubuntu-wallpapers-xenial.deb
dpkg -i /usr/share/debuntu/ubuntu-wallpapers.deb
echo -e "[org/gnome/desktop/interface]\nicon-theme='Papirus'" > /etc/gdm3/greeter.dconf-defaults

systemctl enable unattended-upgrades

echo "" > /etc/network/interfaces
DEBIAN_FRONTEND=noninteractive apt autoremove -y
dconf update
