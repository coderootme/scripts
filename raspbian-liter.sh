#!/bin/bash

# this makes raspbian lite even liter

sudo su
apt update
apt -y purge avahi-daemon bluez bluez-firmware
apt autoremove
systemctl disable dphys-swapfile.service avahi-daemon.service rpi-eeprom-update.service
systemctl disable apt-daily-upgrade.timer apt-daily.timer man-db.timer
swapoff -a
rm /var/swap
apt dist-upgrade
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
echo "" > /etc/motd
{
   echo '#!/bin/sh'
   echo 'uname -sr'
   echo 'echo ""'
   echo 'echo -n "Overlay filesystem on root is now: "'
   echo 'grep -q "boot=overlay" /proc/cmdline && echo -n "\033[0;32menabled" || echo -n "\033[0;31mdisabled"'
   echo 'echo "\033[0m";'
   echo 'echo -n "Boot partition is mounted as:      "'
   echo 'findmnt /boot | grep -q " ro," && echo -n "\033[0;32mread-only" || echo -n "\033[0;31mwritable"'
   echo 'echo "\033[0m"'
   echo 'echo ""'
} > /etc/update-motd.d/10-uname


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


# history cleanup:

unset HISTFILE
echo > /home/pi/.bash_history
echo | sudo tee /root/.bash_history
