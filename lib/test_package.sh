#!/bin/bash
#
# Test basic package installation
#
function test_package {
	local name=$1

	echo -n "it should install $name... "
	dpkg -l | grep -E "^ii\s+$name(\:[^\s]+)?\s" >/dev/null
	result=$?
	[ "$result" -ne 0 ] && echo fail && exit 1
	echo pass
}
