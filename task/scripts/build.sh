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
                   postgresql-client-common \
                   python3-pip \
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

echo "7. Installing jq"
curl -L -o /usr/local/bin/jq "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"
chmod +x /usr/local/bin/jq

echo "8. Installing awscli"
pip3 install awscli

echo "9. Installing terraform"
curl -L -o terraform.zip "https://releases.hashicorp.com/terraform/0.6.16/terraform_0.6.16_linux_amd64.zip"
unzip -d /usr/local/bin terraform.zip
REMOVE_PROVIDERS="atlas azure azurerm clc cloudflare cloudstack cobbler consul datadog digitalocean dme dnsimple docker dyn fastly github google heroku influxdb librato mailgun openstack packet powerdns rundeck softlayer statuscake tls triton ultradns vcd vsphere"
for provider in $REMOVE_PROVIDERS
do
  rm -f /usr/local/bin/terraform-provider-${provider}
done
rm -f terraform.zip

apt-get clean
rm -rf /var/cache/apt
