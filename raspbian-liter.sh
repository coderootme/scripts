#!/bin/bash

# this makes raspbian lite even liter

sudo su
systemctl disable dphys-swapfile.service avahi-daemon.service rpi-eeprom-update.service
systemctl disable apt-daily-upgrade.timer apt-daily.timer man-db.timer
swapoff -a
rm /var/swap
apt update
apt -y purge bluez bluez-firmware
apt -y install vim tmux mc
mkdir -p /tmpfs/
{
   echo ''
   echo 'tmpfs /tmpfs/ tmpfs nodev,nosuid,size=512M   0 0'
} >> /etc/fstab
mount -a
{
   echo ''
   echo 'dtoverlay=disable-bt'
} >> /boot/config.txt
{
   echo ''
   echo 'noarp'
} >> /etc/dhcpcd.conf

# also consider dtparam=audio=off in /boot/config.txt

# also consider watchdog:

sudo su
echo 'dtparam=watchdog=on' >> /boot/config.txt
reboot

sudo su
apt update
apt install watchdog
echo 'watchdog-device = /dev/watchdog' >> /etc/watchdog.conf
echo 'watchdog-timeout = 15' >> /etc/watchdog.conf
echo 'max-load-1 = 24' >> /etc/watchdog.conf
echo 'interface = wlan0' >> /etc/watchdog.conf
systemctl enable --now watchdog
systemctl status watchdog
