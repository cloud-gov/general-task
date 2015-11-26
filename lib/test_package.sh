#!/bin/bash
#
# Test basic package installation
#
function test_package {
  local name=$1
  local version=$2

  echo -n "it should install $name $version... "
  dpkg -l | egrep "^ii\s+$name(\:[^\s]+)?\s+$version" > /dev/null
  [ "$?" -ne 0 ] && echo fail && exit 1
  echo pass
}
