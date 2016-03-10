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
apt-get -y install build-essential \
                   cmake \
                   rake \
                   unzip \
                   curl \
                   git \
                   openssl \
                   ruby2.0 \
                   ruby2.0-dev \
                   sqlite3 \
                   libmysqlclient-dev \
                   libpopt-dev \
                   libpq-dev \
                   libreadline6-dev \
                   libsqlite3-dev \
                   libssl-dev \
                   libcurl4-openssl-dev \
                   libxslt1-dev \
                   libxml2-dev \
                   libyaml-dev \
                   zlibc \
                   zlib1g-dev
# Set default versions of ruby and gem to 2.0 versions
update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.0 1
update-alternatives --install /usr/bin/gem gem /usr/bin/gem2.0 1

echo "4. Installing Spiff"
curl -L -o /tmp/spiff.zip "https://github.com/cloudfoundry-incubator/spiff/releases/download/v$SPIFF_RELEASE_VERSION/spiff_linux_amd64.zip"
unzip /tmp/spiff.zip -d /usr/local/bin
rm -f /tmp/spiff.zip

echo "5. Installing bosh-init"
curl -L -o /usr/local/bin/bosh-init "https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-$BOSH_INIT_RELEASE_VERSION-linux-amd64"
chmod +x /usr/local/bin/bosh-init

echo "6. Installing BOSH CLI"
gem install bosh_cli -v "$BOSH_CLI_RELEASE_VERSION" --no-ri --no-rdoc