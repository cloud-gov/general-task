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
test_package build-essential "$BUILD_ESSENTIAL_VERSION"
test_package cmake "$CMAKE_VERSION"
test_package rake "$RAKE_VERSION"
test_package unzip "$UNZIP_VERSION"
test_package curl "$CURL_VERSION"
test_package git "$GIT_VERSION"
test_package ruby2.0 "$RUBY_VERSION"
test_package ruby2.0-dev "$RUBY_DEV_VERSION"
test_package libmysqlclient-dev "$LIBMYSQLCLIENT_DEV_VERSION"
test_package libpq-dev "$LIBPQ_DEV_VERSION"
test_package libpopt-dev "$LIBPOPT_DEV_VERSION"
test_package libssl-dev "$LIBSSL_DEV_VERSION"
test_package libcurl4-openssl-dev "$LIBCURL4_OPENSSL_DEV_VERSION"
test_package libxslt1-dev "$LIBXSLT1_DEV_VERSION"
test_package libyaml-dev "$LIBYAML_DEV_VERSION"

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
