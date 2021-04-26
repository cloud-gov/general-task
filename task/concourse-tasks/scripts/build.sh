#!/bin/bash

set -e

#
# Source configuration environment variables
#
source ./config.sh

# Install current postgres
apt-get update
apt-get -y -q install \
  gnupg2 \
  lsb-release \
  software-properties-common \
  tzdata \
  wget \

echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -

echo "Updating system timezone"
ln -sf "/usr/share/zoneinfo/$SYSTEM_TIMEZONE" /etc/localtime

echo "Updating system package registry"
add-apt-repository ppa:rmescandon/yq
apt-get -y update

echo "Installing basic libraries and development utilities"
apt-get -y install \
  build-essential \
  cmake \
  curl \
  dnsutils \
  git \
  libcurl4-openssl-dev \
  libmysqlclient-dev \
  libpopt-dev \
  libpq-dev \
  libreadline6-dev \
  libsqlite3-dev \
  libssl-dev \
  libxml2-dev \
  libxslt1-dev \
  libyaml-dev \
  openssl \
  postgresql-client \
  postgresql-client-common \
  python3-openssl \
  python3-pip \
  rake \
  ruby \
  ruby-dev \
  sqlite3 \
  unzip \
  vim \
  whois \
  yq \
  zlibc \

# Commented out pending https://bugs.launchpad.net/ubuntu/+source/ruby2.0/+bug/1777174
# # Set default versions of ruby and gem to 2.0 versions
# update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.0 1
# update-alternatives --install /usr/bin/gem gem /usr/bin/gem2.0 1
gem install bundler --no-ri --no-rdoc

echo "Installing Spruce version ${SPRUCE_RELEASE_VERSION}"
curl -L -o /usr/local/bin/spruce "https://github.com/geofffranks/spruce/releases/download/v$SPRUCE_RELEASE_VERSION/spruce-linux-amd64"
chmod +x /usr/local/bin/spruce

echo "Installing jq version ${JQ_RELEASE_VERSION}"
curl -L -o /usr/local/bin/jq "https://github.com/stedolan/jq/releases/download/jq-$JQ_RELEASE_VERSION/jq-linux64"
chmod +x /usr/local/bin/jq

echo "Installing awscli"
pip3 install awscli

echo "Installing terraform version ${TERRAFORM_TEST_RELEASE_VERSION} "
curl -L -o terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_TEST_RELEASE_VERSION}/terraform_${TERRAFORM_TEST_RELEASE_VERSION}_linux_amd64.zip"
unzip -d /usr/local/bin terraform.zip
mv /usr/local/bin/terraform /usr/local/bin/terratest-14.10
rm -f terraform.zip

echo "Installing terraform version ${TERRAFORM_RELEASE_VERSION} "
curl -L -o terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_RELEASE_VERSION}/terraform_${TERRAFORM_RELEASE_VERSION}_linux_amd64.zip"
unzip -d /usr/local/bin terraform.zip
rm -f terraform.zip

echo "Installing CF Client version 6 ${CF_CLI_RELEASE_VERSION6}"
curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&version=${CF_CLI_RELEASE_VERSION6}" | tar -zx -C /usr/local/bin
mv /usr/local/bin/cf /usr/local/bin/cf6

echo "Installing CF Client version 7 ${CF_CLI_RELEASE_VERSION7}"
curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&version=${CF_CLI_RELEASE_VERSION7}" | tar -zx -C /usr/local/bin
mv /usr/local/bin/cf7 /usr/local/bin/cf

echo "Installing Credhub Client version ${CREDHUB_CLI_RELEASE_VERSION}"
curl -L "https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_CLI_RELEASE_VERSION}/credhub-linux-${CREDHUB_CLI_RELEASE_VERSION}.tgz" | tar -zx -C /usr/local/bin

echo "Installing Concourse Client"
curl -L "https://github.com/concourse/concourse/releases/download/v${CONCOURSE_CLI_RELEASE_VERSION}/concourse-${CONCOURSE_CLI_RELEASE_VERSION}-linux-amd64.tgz" | tar -zx -C /usr/local/bin

# Commented out pending https://bugs.launchpad.net/ubuntu/+source/ruby2.0/+bug/1777174
echo "Installing uaac"
gem install cf-uaac -v "$UAAC_CLI_RELEASE_VERSION" --no-ri --no-rdoc

echo "Installing BOSH CLI v2 version ${BOSH_CLI_V2_RELEASE_VERSION}"
curl -L -o /usr/local/bin/bosh "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${BOSH_CLI_V2_RELEASE_VERSION}-linux-amd64"
chmod +x /usr/local/bin/bosh
ln -s /usr/local/bin/bosh /usr/local/bin/bosh2
ln -s /usr/local/bin/bosh /usr/local/bin/bosh-cli

# todo (mxplusb): update to current version of go
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

echo "Installing Bats BASH testing framework"
git clone https://github.com/sstephenson/bats.git /tmp/bats-repo
pushd /tmp/bats-repo
./install.sh /usr/local
popd
rm -rf /tmp/bats-repo

echo "Installing Doomsday CLI"
wget https://github.com/doomsday-project/doomsday/releases/latest/download/doomsday-linux
chmod a+x doomsday-linux
mv ./doomsday-linux /usr/bin/doomsday

echo "Installing new UAA client."
wget https://github.com/cloudfoundry-incubator/uaa-cli/releases/download/0.10.0/uaa-linux-amd64-0.10.0
mv uaa-linux-amd64-0.10.0 /usr/bin/uaa
chmod a+x /usr/bin/uaa
