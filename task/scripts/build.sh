#!/bin/bash

#
# Source configuration environment variables
#
source ./config.sh

echo "1. Updating system timezone"
ln -sf "/usr/share/zoneinfo/$SYSTEM_TIMEZONE" /etc/localtime

echo "2. Updating system package registry"
apt-get -y update

echo "3. Installing basic libraries and development utilities"
apt-get -y install build-essential="$BUILD_ESSENTIAL_VERSION" \
                   cmake="$CMAKE_VERSION" \
                   rake="$RAKE_VERSION" \
                   unzip="$UNZIP_VERSION" \
                   curl="$CURL_VERSION" \
                   git="$GIT_VERSION" \
                   libpopt-dev="$LIBPOPT_DEV_VERSION" \
                   libssl-dev="$LIBSSL_DEV_VERSION" \
                   libcurl4-openssl-dev="$LIBCURL4_OPENSSL_DEV_VERSION" \
                   libxslt1-dev="$LIBXSLT1_DEV_VERSION" \
                   libyaml-dev="$LIBYAML_DEV_VERSION"

echo "4. Installing Spiff"
curl -L -o /tmp/spiff.zip "https://github.com/cloudfoundry-incubator/spiff/releases/download/v$SPIFF_RELEASE_VERSION/spiff_linux_amd64.zip"
unzip /tmp/spiff.zip -d /usr/local/bin
rm -f /tmp/spiff.zip