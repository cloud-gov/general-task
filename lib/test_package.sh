#!/bin/bash
#
# Test basic package installation
#
function test_package {
  local name=$1

  echo -n "it should install $name... "
  dpkg -l | egrep "^ii\s+$name(\:[^\s]+)?\s" > /dev/null
  [ "$?" -ne 0 ] && echo fail && exit 1
  echo pass
}
