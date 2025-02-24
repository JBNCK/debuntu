#!/usr/bin/bash
set -e
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 
    exit 1
fi

apt update && DEBIAN_FRONTEND=noninteractive apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install gnupg curl -y

echo "deb http://deb.debian.org/debian stable-backports main contrib non-free" > /etc/apt/sources.list.d/debian-backports.list
apt update
DEBIAN_FRONTEND=noninteractive apt -t stable-backports install linux-image-amd64 linux-headers-amd64 -y
echo -e "Package: *\nPin: release a=stable-backports\nPin-Priority: 500" > /etc/apt/preferences.d/kernel-backports

set +e
mkdir -v /etc/dconf/profile
mkdir -v /etc/dconf/db/local.d
set -e
cp -R etc/ /
cp -R usr/ /

set +e
dpkg -i /usr/share/debuntu/debuntu-meta.deb
set -e
DEBIAN_FRONTEND=noninteractive apt install -f -y --no-install-recommends

DEBIAN_FRONTEND=noninteractive apt install gnome-shell-extension-appindicator gnome-shell-extension-dashtodock gnome-shell-extension-desktop-icons-ng flatpak gnome-software-plugin-flatpak geary gnome-calendar gnome-calculator eog vlc -y
DEBIAN_FRONTEND=noninteractive apt -t stable-backports install tlp tlp-rdw -y
DEBIAN_FRONTEND=noninteractive apt install --install-recommends fonts-noto -y
flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo

dpkg -i /usr/share/debuntu/ubuntu-wallpapers-xenial.deb
dpkg -i /usr/share/debuntu/ubuntu-wallpapers.deb

(cd /tmp && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg)
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt update
DEBIAN_FRONTEND=noninteractive apt install google-chrome-stable -y

dconf update
/sbin/reboot
