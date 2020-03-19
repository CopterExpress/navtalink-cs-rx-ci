#! /usr/bin/env bash

#
# Script for install software to the image.
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
  TEXT="\e[1m${TEXT}\e[0m" # BOLD

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

# https://gist.github.com/letmaik/caa0f6cc4375cbfcc1ff26bd4530c2a3
# https://github.com/travis-ci/travis-build/blob/master/lib/travis/build/templates/header.sh
my_travis_retry() {
  local result=0
  local count=1
  while [ $count -le 3 ]; do
    [ $result -ne 0 ] && {
      echo -e "\n${ANSI_RED}The command \"$@\" failed. Retrying, $count of 3.${ANSI_RESET}\n" >&2
    }
    # ! { } ignores set -e, see https://stackoverflow.com/a/4073372
    ! { "$@"; result=$?; }
    [ $result -eq 0 ] && break
    count=$(($count + 1))
    sleep 1
  done

  [ $count -gt 3 ] && {
    echo -e "\n${ANSI_RED}The command \"$@\" failed 3 times.${ANSI_RESET}\n" >&2
  }

  return $result
}

echo_stamp "Update apt"
apt-get update
#&& apt upgrade -y

echo_stamp "Software installing"
apt-get install --no-install-recommends -y \
iptables-persistent \
&& echo_stamp "Everything was installed!" "SUCCESS" \
|| (echo_stamp "Some packages wasn't installed!" "ERROR"; exit 1)

echo_stamp "Select legacy iptables"
update-alternatives --set iptables /usr/sbin/iptables-legacy \
&& echo_stamp "Legacy iptables was selected!" "SUCCESS" \
|| (echo_stamp "Failed to select legacy iptables!" "ERROR"; exit 1)

echo_stamp "Set GS role"
cp -f /home/pi/navtalink/wifibroadcast.cfg.gs /boot/wifibroadcast.txt \
&& systemctl enable wifibroadcast@gs \
&& echo_stamp "GS role was set!" "SUCCESS" \
|| (echo_stamp "Failed to set role!" "ERROR"; exit 1)

echo_stamp "End of software installation"
