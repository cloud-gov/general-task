#!/bin/bash
#
# Test system timezone
#
function test_timezone {
  local timezone=$1

  echo -n "it should set the system timezone to $timezone... "
  if ! diff /etc/localtime "/usr/share/zoneinfo/$timezone"
  then
    echo fail && exit 1
  fi
  echo pass
}
