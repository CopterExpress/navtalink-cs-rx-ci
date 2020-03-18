#! /usr/bin/env bash

#
# Script for network configure
#
# Copyright (C) 2020 Copter Express Technologies
#
# Author: Artem Smirnov <urpylka@gmail.com>
# Author: Andrey Dvornikov <dvornikov-aa@yandex.ru>
#

set -e # Exit immidiately on non-zero result

echo_stamp() {
  # TEMPLATE: echo_stamp <TEXT> <TYPE>
  # TYPE: SUCCESS, ERROR, INFO

  # More info there https://www.shellhacks.com/ru/bash-colors/

  TEXT="$(date '+[%Y-%m-%d %H:%M:%S]') $1"
  TEXT="\e[1m$TEXT\e[0m" # BOLD

  case "$2" in
    SUCCESS)
    TEXT="\e[32m${TEXT}\e[0m";; # GREEN
    ERROR)
    TEXT="\e[31m${TEXT}\e[0m";; # RED
    *)
    TEXT="\e[34m${TEXT}\e[0m";; # BLUE
  esac
  echo -e ${TEXT}
}

echo "#1 Remove wpa_supplicant configurations"
rm /etc/wpa_supplicant/wpa_supplicant-* || true

echo "#2 Remove dnsmasq configuration and disable dnsmasq"
rm /etc/dnsmasq.conf || true
systemctl disable dnsmasq

echo "#3 Enable IPv4 forwarding"
sed -i '/net.ipv4.ip_forward=1/s/^#//g' /etc/sysctl.conf

echo "#4 Disable static IP for the internal WLAN"
sed -i '/interface wlan0/d' /etc/dhcpcd.conf
sed -i '/interface wlan1/d' /etc/dhcpcd.conf
sed -i '/interface wlan2/d' /etc/dhcpcd.conf
sed -i '/interface wlan3/d' /etc/dhcpcd.conf
sed -i '/static ip_address=192.168.30.1\/24/d' /etc/dhcpcd.conf

echo_stamp "#5 End of network installation"
