#!/bin/bash

#
# Source configuration environment variables
#
source ./config.sh
#
# Source library functions
#
for file in /opt/concourse-ci/task/lib/*.sh
  do source $file
done

echo "--- TESTS ---"

#
# Test system information
#
echo "1. Testing system configuration"
test_timezone "$SYSTEM_TIMEZONE"
