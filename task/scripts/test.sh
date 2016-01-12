#!/bin/bash

#
# Source configuration environment variables
#
source ./config.sh

#
# Source library functions
#
for file in /opt/concourse-ci/lib/*.sh
  do source $file
done

echo "--- TESTS ---"

#
# Test system information
#
echo "1. Testing system configuration"
test_timezone "$SYSTEM_TIMEZONE"

#
# Test installed packages
#
echo "2. Testing installed packages"
test_package build-essential
test_package cmake
test_package rake
test_package unzip
test_package curl
test_package git
test_package ruby2.0
test_package ruby2.0-dev
test_package libmysqlclient-dev
test_package libpq-dev
test_package libpopt-dev
test_package libssl-dev
test_package libcurl4-openssl-dev
test_package libxslt1-dev
test_package libyaml-dev

#
# Test installed commands
#
echo "3. Testing installed commands"
test_command make "$MAKE_CMD_VERSION"
test_command cmake "$CMAKE_CMD_VERSION"
test_command rake "$RAKE_CMD_VERSION"
test_command ruby "$RUBY_CMD_VERSION"
test_command gem "$GEM_CMD_VERSION"
test_command openssl "$OPENSSL_CMD_VERSION" version
test_command unzip "$UNZIP_CMD_VERSION"
test_command curl "$CURL_CMD_VERSION"
test_command git "$GIT_CMD_VERSION"
test_command spiff "$SPIFF_RELEASE_VERSION"
test_command bosh "$BOSH_CLI_RELEASE_VERSION"
