#! /usr/bin/env bash

#
# Script for build the image. Used builder script of the target repo
# For build: docker run --privileged -it --rm -v /dev:/dev -v $(pwd):/builder/repo smirart/builder
#
# Copyright (C) 2019 Copter Express Technologies
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

echo_stamp "Rename SSID"
NEW_SSID='NAVTALINK-CS-RX-'$(head -c 100 /dev/urandom | xxd -ps -c 100 | sed -e "s/[^0-9]//g" | cut -c 1-4)
navtalink_rename ${NEW_SSID}

echo_stamp "Harware setup"
/root/hardware_setup.sh

echo_stamp "Remove init scripts"
rm /root/init_rpi.sh /root/hardware_setup.sh

echo_stamp "Enable port forwarding"
iptables -t nat -A PREROUTING -p tcp -m tcp -i eth0 --dport 5901 -j DNAT --to-destination 10.5.0.2:5901
iptables -t nat -A PREROUTING -p tcp -m tcp -i eth0 --dport 2222 -j DNAT --to-destination 10.5.0.2:22
iptables -t nat -A POSTROUTING -o gs-wfb -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

echo_stamp "End of initialization of the image"
