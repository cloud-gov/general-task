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

#
# Test installed packages
#
echo "2. Testing installed packages"
test_package build-essential
test_package cmake
test_package curl
test_package git
test_package libcurl4-openssl-dev
test_package libmysqlclient-dev
test_package libpopt-dev
test_package libpq-dev
test_package libreadline-dev
test_package libsqlite3-dev
test_package libssl-dev
test_package libxml2-dev
test_package libxslt1-dev
test_package libyaml-dev
test_package openssl
test_package sqlite3
test_package unzip
test_package zlib1g-dev
test_package python3-pip

#
# Test installed commands
#
echo "3. Testing installed commands"
test_command bats
test_command bosh "$BOSH_CLI_V2_RELEASE_VERSION"
test_command cf "$CF_CLI_RELEASE_VERSION7"
test_command cmake
test_command curl
test_command gem
test_command git "$GIT_CMD_VERSION"
test_command jq
test_command make
test_command rake
test_command ruby "$RUBY_RELEASE_VERSION"
test_command terraform
test_command uaac
test_command unzip
test_command go "go$GO_VERSION" version
test_command yq
test_command node
test_command python "$PYTHON_CMD_VERSION"
test_command ssh


# we need to source .profile to load nvm scripts. We're waiting until now to
# do so because sourcing it is the exception, so it's more important that
# other things work _without_ sourcing .profile
source ~/.profile
test_command nvm
