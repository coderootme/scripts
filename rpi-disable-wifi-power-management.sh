#!/bin/bash

{
   echo '[Unit]'
   echo 'Description=Disable WiFi power management'
   echo 'After=network.target'
   echo
   echo '[Service]'
   echo 'ExecStart=/usr/sbin/iwconfig wlan0 power off'
   echo
   echo '[Install]'
   echo 'WantedBy=multi-user.target'
   echo
} > /lib/systemd/system/wifipower.service

systemctl enable --now wifipower.service
