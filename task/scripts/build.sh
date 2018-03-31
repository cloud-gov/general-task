#!/bin/bash

set -e

#
# Source configuration environment variables
#
source ./config.sh

# Install current postgres
apt-get update && apt-get -y -q install wget
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -

echo "Updating system timezone"
ln -sf "/usr/share/zoneinfo/$SYSTEM_TIMEZONE" /etc/localtime

echo "Updating system package registry"
apt-get -y update

echo "Installing basic libraries and development utilities"
apt-get -y install build-essential \
                   cmake \
                   rake \
                   unzip \
                   curl \
                   dnsutils \
                   git \
                   openssl \
                   whois \
                   postgresql-client \
                   postgresql-client-common \
                   python3-pip \
                   python3-openssl \
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
                   vim-tiny
# Set default versions of ruby and gem to 2.0 versions
update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.0 1
update-alternatives --install /usr/bin/gem gem /usr/bin/gem2.0 1
gem install bundler --no-ri --no-rdoc

echo "Installing Spruce"
curl -L -o /usr/local/bin/spruce "https://github.com/geofffranks/spruce/releases/download/v$SPRUCE_RELEASE_VERSION/spruce-linux-amd64"
chmod +x /usr/local/bin/spruce

echo "Installing jq"
curl -L -o /usr/local/bin/jq "https://github.com/stedolan/jq/releases/download/jq-$JQ_RELEASE_VERSION/jq-linux64"
chmod +x /usr/local/bin/jq

echo "Installing awscli"
pip3 install awscli

echo "Installing terraform"
curl -L -o terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_RELEASE_VERSION}/terraform_${TERRAFORM_RELEASE_VERSION}_linux_amd64.zip"
unzip -d /usr/local/bin terraform.zip
rm -f terraform.zip

echo "Installing CF Client"
curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&version=${CF_CLI_RELEASE_VERSION}" | tar -zx -C /usr/local/bin

echo "Installing uaac"
# must pin public_suffix to <3.0 on 14.04 when using UAAC >=4.0
gem install public_suffix -v "<3.0"  --no-ri --no-rdoc
gem install cf-uaac -v "$UAAC_CLI_RELEASE_VERSION" --no-ri --no-rdoc

echo "Installing BOSH CLI v2"
curl -L -o /usr/local/bin/bosh "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${BOSH_CLI_V2_RELEASE_VERSION}-linux-amd64"
chmod +x /usr/local/bin/bosh
ln -s /usr/local/bin/bosh /usr/local/bin/bosh2
ln -s /usr/local/bin/bosh /usr/local/bin/bosh-cli

echo "Installing bosh-lint"
mkdir -p /goroot
curl https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1

export GOROOT=/goroot
export PATH=$GOROOT/bin:$PATH

git clone https://github.com/cppforlife/bosh-lint
pushd bosh-lint
  source .envrc
  ./bin/build
  mv out/bosh-ext /usr/local/bin/bosh-ext
popd
ln -s /usr/local/bin/bosh-ext /usr/local/bin/bosh-lint
rm -rf bosh-lint

apt-get clean
rm -rf /var/cache/apt

echo "Installing Terraform cloudfoundry provider"
TARGET="/root/.terraform.d/providers/terraform-provider-cloudfoundry"
mkdir -p $(dirname $TARGET)
curl -L https://github.com/orange-cloudfoundry/terraform-provider-cloudfoundry/releases/download/${TERRAFORM_CF_PROVIDER_RELEASE_VERSION}/terraform-provider-cloudfoundry_0.9_linux_amd64 > ${TARGET}
chmod 755 ${TARGET}

echo "Installing Terraform PowerDNS provider"

export GOPATH=$HOME/go
PROVIDERS=/root/.terraform.d/providers

# TODO: Revert after patches are accepted upstream
go get -d github.com/18F/terraform-provider-powerdns
mkdir -p $GOPATH/src/github.com/terraform-providers
rm -rf $GOPATH/src/github.com/terraform-providers/terraform-provider-powerdns
mv $GOPATH/src/github.com/18F/terraform-provider-powerdns $GOPATH/src/github.com/terraform-providers
pushd $GOPATH/src/github.com/terraform-providers/terraform-provider-powerdns
  go build
  mkdir -p "${PROVIDERS}"
  cp terraform-provider-powerdns "${PROVIDERS}"
popd

TARGET="/root/.terraform.d/providers/terraform-provider-cloudfoundry"
mkdir -p $(dirname $TARGET)
curl -L https://github.com/orange-cloudfoundry/terraform-provider-cloudfoundry/releases/download/${TERRAFORM_CF_PROVIDER_RELEASE_VERSION}/terraform-provider-cloudfoundry_0.9_linux_amd64 > ${TARGET}
chmod 755 ${TARGET}

cat <<EOF >> ~/.terraformrc
providers {
  cloudfoundry = "${TARGET}"
  powerdns = "${PROVIDERS}/terraform-provider-powerdns"
}

EOF

echo "Installing Bats BASH testing framework"
git clone https://github.com/sstephenson/bats.git /tmp/bats-repo
pushd /tmp/bats-repo
./install.sh /usr/local
popd
rm -rf /tmp/bats-repo
