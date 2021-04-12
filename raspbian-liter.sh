#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

confirm_action(){
   echo
   while true; do
      if [[ "$2" == 'Y' || "$2" == 'y' ]]; then
         question="$1 [Y/n]: "
      elif [[ "$2" == 'N' || "$2" == 'n' ]]; then
         question="$1 [y/N]: "
      else
         question="$1 [y/n]: "
      fi
      echo -n "$question"
      read -r answer
      if [ "$2" ]; then
         answer=${answer:-"$2"}
      fi
      if [[ $answer = "Y" || $answer = "y" ]]; then
         return 0
         break
      elif [[ $answer = "n" ]]; then
         return 1
         break
      else
         echo "Invalid answer. Please, try again."
      fi
   done
}

echo_success(){
   echo "$GREEN" "[OK]" "$NORMAL"
}

echo_fail(){
   echo "$RED" "[FAIL]" "$NORMAL"
}

echo_process(){
   printf '%-50s' "$1"
}

if [[ $EUID -ne 0 ]]; then
   echo 'This script must be run as root.'
   exit 1
fi

if confirm_action "Do you want to permanently disable swap?" "y"; then
   echo_process 'Disabling swap ... '
   if systemctl disable -q --now dphys-swapfile.service; then echo_success; else echo_fail; fi
   echo_process 'Removing swap file ... '
   if rm -f /var/swap; then echo_success; else echo_fail; fi
fi

if confirm_action "Do you want to update the apt cache?" "y"; then
   echo_process 'Updating apt cache ... '
   echo
   if apt-get -q update; then echo_process; echo_success; else echo_process; echo_fail; fi
fi

if confirm_action "Disable avahi-daemon?" "y"; then
   echo_process 'Disabling avahi-daemon ... '
   if systemctl is-active --quiet avahi-daemon.service; then
      if systemctl disable -q --now avahi-daemon.service; then echo_success; else echo_fail; fi
   else
      echo_success;
   fi
   echo_process 'Removing avahi-daemon ... '
   if apt-get -qq purge avahi-daemon; then echo_success; else echo_fail; fi
fi

if confirm_action "Disable rpi-eeprom-update?" "y"; then
   echo_process 'Disabling rpi-eeprom-update ... '
   if systemctl disable -q --now rpi-eeprom-update.service; then echo_success; else echo_fail; fi
fi

if confirm_action "Disable apt-daily timers?" "y"; then
   echo_process 'Disabling apt-daily timers ... '
   if systemctl disable -q --now apt-daily-upgrade.timer apt-daily.timer man-db.timer; then echo_success; else echo_fail; fi
fi

if confirm_action "Disable cron service?" "y"; then
   echo_process 'Disabling cron service ... '
   if systemctl disable -q --now cron; then echo_success; else echo_fail; fi
fi

if confirm_action "Disable triggerhappy?" "y"; then
   echo_process 'Disabling triggerhappy ... '
   if systemctl disable -q --now triggerhappy; then echo_success; else echo_fail; fi
fi

if confirm_action "Disable bluetooth?" "y"; then
   echo_process 'Disabling bluetooth ... '
   if grep -q '^dtoverlay=disable-bt' /boot/config.txt; then
      echo_success
   else
      if {
         echo ''
         echo 'dtoverlay=disable-bt'
      } | tee -a /boot/config.txt > /dev/null 2>&1; then echo_success; else echo_fail; fi
   fi
   echo_process 'Removing bluez ... '
   if apt-get -qq purge bluez bluez-firmware; then echo_success; else echo_fail; fi
fi

if confirm_action "Disable Wi-Fi?" "y"; then
   echo_process 'Disabling Wi-Fi ... '
   if grep -q '^dtoverlay=disable-wifi' /boot/config.txt; then
      echo_success
   else
      if {
         echo ''
         echo 'dtoverlay=disable-wifi'
      } | tee -a /boot/config.txt > /dev/null 2>&1; then echo_success; else echo_fail; fi
   fi
fi

if confirm_action "Disable LEDs on the ethernet port?" "y"; then
   if grep -q 'Raspberry Pi 3' /proc/device-tree/model; then
      eth_value=14
   else
      eth_value=4
   fi

   echo_process 'Disabling LED0 ... '
   if grep -q "^dtparam=eth_led0=$eth_value" /boot/config.txt; then
      echo_success
   else
      if {
         echo ''
         echo "dtparam=eth_led0=$eth_value"
      } | tee -a /boot/config.txt > /dev/null 2>&1; then echo_success; else echo_fail; fi
   fi

   echo_process 'Disabling LED1 ... '
   if grep -q "^dtparam=eth_led1=$eth_value" /boot/config.txt; then
      echo_success
   else
      if {
         echo ''
         echo "dtparam=eth_led1=$eth_value"
      } | tee -a /boot/config.txt > /dev/null 2>&1; then echo_success; else echo_fail; fi
   fi

fi

if confirm_action "Install vim, tmux, mc, nmap and ncdu?" "y"; then
   echo_process 'Installing ... '
   if apt-get -qq install vim tmux mc nmap ncdu; then echo_success; else echo_fail; fi
fi

if confirm_action "Run dist-upgrade?" "y"; then
   echo_process 'Upgrading ... '
   echo
   if apt dist-upgrade; then echo_process; echo_success; else echo_process; echo_fail; fi
fi

if confirm_action "Deploy /tmpfs/ ?" "y"; then
   echo_process 'mkdir /tmpfs/ ... '
   if mkdir -p /tmpfs/; then echo_success; else echo_fail; fi
   echo_process 'Editing fstab ... '
   if grep -q '^tmpfs /tmpfs' /etc/fstab; then
      echo_success
   else
      if {
         echo ''
         echo 'tmpfs /tmpfs/ tmpfs nodev,nosuid,size=512M   0 0'
      } | tee -a /etc/fstab > /dev/null 2>&1; then echo_success; else echo_fail; fi
   fi
   echo_process 'Mounting fstab ... '
   if mount -a; then echo_success; else echo_fail; fi
fi

if confirm_action "Disable ARP ?" "y"; then
   echo_process 'Disabling ARP ... '
   if grep -q '^noarp' /etc/dhcpcd.conf; then
      echo_success
   else
      if {
         echo ''
         echo 'noarp'
      } | tee -a /etc/dhcpcd.conf > /dev/null 2>&1; then echo_success; else echo_fail; fi
   fi
fi

if confirm_action "Customize MOTD?" "y"; then
   echo_process 'Customizing /etc/motd ... '
   if echo "" > /etc/motd; then echo_success; else echo_fail; fi
   echo_process 'Customizing /etc/update-motd.d/ ... '
   if {
      echo '#!/bin/sh'
      echo 'echo ""'
      echo 'uname -sr'
      echo 'echo ""'
      echo 'echo -n "Temperature:  "'
      echo '/opt/vc/bin/vcgencmd measure_temp | cut -d'=' -f2'
      echo 'echo -n "Load average: "'
      # shellcheck disable=SC2016
      echo 'awk '\''{print $1 " " $2 " " $3}'\'' /proc/loadavg'
      echo 'echo ""'
      echo 'echo -n "Overlay filesystem on root is now: "'
      echo 'grep -q "boot=overlay" /proc/cmdline && echo -n "\033[0;32menabled" || echo -n "\033[0;31mdisabled"'
      echo 'echo "\033[0m";'
      echo 'echo -n "Boot partition is mounted as:      "'
      echo 'findmnt /boot | grep -q " ro," && echo -n "\033[0;32mread-only" || echo -n "\033[0;31mwritable"'
      echo 'echo "\033[0m"'
   } | tee /etc/update-motd.d/10-uname > /dev/null 2>&1; then echo_success; else echo_fail; fi
fi

if confirm_action "Run autoremove?" "y"; then
   echo_process 'Autoremoving ... '
   if apt-get -qq autoremove; then echo_success; else c; fi
fi

if confirm_action "Disable internal soundcard?" "y"; then
   echo_process 'Disabling ... '
   if sed -i '/dtparam=audio/c\dtparam=audio=off' /boot/config.txt; then echo_success; else echo_fail; fi
fi

if confirm_action "Enable watchdog?" "y"; then
   echo_process 'Enabling ... '
   if grep -q '^dtparam=watchdog=on' /boot/config.txt; then
      echo_success
   else
      if {
         echo ''
         echo 'dtparam=watchdog=on'
      } | tee -a /boot/config.txt > /dev/null 2>&1; then echo_success; else echo_fail; fi
   fi

   echo_process 'Configuring ... '
   if sed -i '/RuntimeWatchdogSec=/c\RuntimeWatchdogSec=10' /etc/systemd/system.conf; then echo_success; else echo_fail; fi

   echo_process 'Configuring ... '
   if sed -i '/ShutdownWatchdogSec=/c\ShutdownWatchdogSec=3min' /etc/systemd/system.conf; then echo_success; else echo_fail; fi
fi

if confirm_action "Clear history?" "y"; then
   echo_process 'Removing /home/pi/.bash_history ... '
   if rm -f /home/pi/.bash_history; then echo_success; else echo_fail; fi
   echo_process 'Removing /root/.bash_history ... '
   if rm -f /root/.bash_history; then echo_success; else echo_fail; fi
fi

echo 'All done! You should reboot now!'
