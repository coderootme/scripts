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

