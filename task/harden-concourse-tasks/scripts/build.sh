#!/bin/bash

set -e

#
# Source configuration environment variables
#
source ./config.sh

echo "Configuring ua attach config"
cat <<EOF >> ua-attach-config.yaml
token: $TOKEN
enable_services:
- usg
- esm-infra

EOF

apt-get update
apt-get -y -q install \
  apt-utils \
  gnupg2 \
  tzdata \
  wget \
  software-properties-common \
  lsb-release \
  ubuntu-advantage-tools ca-certificates \

#install postgres
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -

echo "Updating system timezone"
ln -sf "/usr/share/zoneinfo/$SYSTEM_TIMEZONE" /etc/localtime

echo "Updating system package registry"
add-apt-repository ppa:rmescandon/yq
apt-get -y update

echo "Installing basic libraries and development utilities"
apt-get -y -q install \
  build-essential \
  zlib1g-dev \
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
  libreadline-dev \
  libxml2-dev \
  libxslt1-dev \
  libyaml-dev \
  openssl \
  postgresql-client \
  postgresql-client-common \
  sqlite3 \
  unzip \
  vim \
  whois \
  rsync \
  libffi-dev \
  yq \
  python3-pip \

#upgrade pip and install necessary packages
echo "Upgrading python packages"
pip3 install --upgrade pip
pip3 install setuptools -U
pip3 install wheel -U
pip3 install oauthlib -U
pip3 install pyopenssl -U
pip3 install pyyaml -U
pip3 install PyJWT -U
pip3 install cryptography -U

echo "Installing awscli"
pip3 install awscli

echo "UA attaching"
ua attach --attach-config ua-attach-config.yaml

apt-get -y -q install \
  usg \

#install nodejs using nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

nvm install $NODE_VERSION
npm install minimist

# Install Ruby from source
wget "https://cache.ruby-lang.org/pub/ruby/3.2/ruby-${RUBY_RELEASE_VERSION}.tar.gz"
tar xvaf "ruby-${RUBY_RELEASE_VERSION}.tar.gz"
pushd "ruby-${RUBY_RELEASE_VERSION}"
  ./configure
  make
  make install
popd
rm -f "ruby-${RUBY_RELEASE_VERSION}.tar.gz"

# # Commented out pending https://bugs.launchpad.net/ubuntu/+source/ruby2.0/+bug/1777174
# # # Set default versions of ruby and gem to 2.0 versions
# # update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.0 1
# # update-alternatives --install /usr/bin/gem gem /usr/bin/gem2.0 1

# Install Bundler
gem install bundler -v "${BUNDLER_RELEASE_VERSION}" --no-document

# Install Rake
gem install rake -v "${RAKE_RELEASE_VERSION}" --no-document

# Install RDoc
gem install rdoc -v "${RDOC_RELEASE_VERSION}"

# Install CGI
gem install cgi -v "${CGI_RELEASE_VERSION}"

# Install Rexml
gem install rexml -v "${REXML_RELEASE_VERSION}"

echo "Installing Spruce version ${SPRUCE_RELEASE_VERSION}"
curl -L -o /usr/local/bin/spruce "https://github.com/geofffranks/spruce/releases/download/v$SPRUCE_RELEASE_VERSION/spruce-linux-amd64"
chmod +x /usr/local/bin/spruce

echo "Installing jq version ${JQ_RELEASE_VERSION}"
curl -L -o /usr/local/bin/jq "https://github.com/stedolan/jq/releases/download/jq-$JQ_RELEASE_VERSION/jq-linux64"
chmod +x /usr/local/bin/jq

echo "Installing terraform version ${TERRAFORM_TEST_RELEASE_VERSION} "
curl -L -o terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_TEST_RELEASE_VERSION}/terraform_${TERRAFORM_TEST_RELEASE_VERSION}_linux_amd64.zip"
unzip -d /usr/local/bin terraform.zip
mv /usr/local/bin/terraform /usr/local/bin/terratest-1.1
rm -f terraform.zip

echo "Installing terraform version ${TERRAFORM_RELEASE_VERSION} "
curl -L -o terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_RELEASE_VERSION}/terraform_${TERRAFORM_RELEASE_VERSION}_linux_amd64.zip"
unzip -d /usr/local/bin terraform.zip
rm -f terraform.zip

echo "Installing CF Client version 7 ${CF_CLI_RELEASE_VERSION7}"
curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&version=${CF_CLI_RELEASE_VERSION7}" | tar -zx -C /usr/local/bin
mv /usr/local/bin/cf7 /usr/local/bin/cf

echo "Installing Credhub Client version ${CREDHUB_CLI_RELEASE_VERSION}"
curl -L "https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_CLI_RELEASE_VERSION}/credhub-linux-${CREDHUB_CLI_RELEASE_VERSION}.tgz" | tar -zx -C /usr/local/bin

# Commented out pending https://bugs.launchpad.net/ubuntu/+source/ruby2.0/+bug/1777174
echo "Installing uaac"
gem install cf-uaac -v "$UAAC_CLI_RELEASE_VERSION" --no-document

echo "Installing BOSH CLI v2 version ${BOSH_CLI_V2_RELEASE_VERSION}"
curl -L -o /usr/local/bin/bosh "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${BOSH_CLI_V2_RELEASE_VERSION}-linux-amd64"
chmod +x /usr/local/bin/bosh
ln -s /usr/local/bin/bosh /usr/local/bin/bosh2
ln -s /usr/local/bin/bosh /usr/local/bin/bosh-cli

echo "Installing Go"
curl -OL "https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz"
mkdir -p /usr/local/go
tar -xvzf "go$GO_VERSION.linux-amd64.tar.gz" -C /usr/local/go --strip-components=1
ln -s /usr/local/go/bin/go /usr/local/bin/go
ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

go env -w GOBIN=/usr/local/bin

apt-get clean
rm -rf /var/cache/apt

echo "Configuring TF CLI local provider_installation"
cat <<EOF >> ~/.terraformrc
provider_installation {
  filesystem_mirror {
    path    = "$HOME/.terraform-providers/"
    include = ["local/providers/*"]
  }
  direct {
    exclude = ["local/providers/*"]
  }
}
EOF

echo "Installing Bats BASH testing framework"
git clone https://github.com/sstephenson/bats.git /tmp/bats-repo
pushd /tmp/bats-repo
./install.sh /usr/local
popd
rm -rf /tmp/bats-repo

echo "Installing Doomsday CLI"
wget https://github.com/cloud-gov/cg-doomsday/releases/download/1.0.0/doomsday-linux-amd64
chmod a+x doomsday-linux-amd64
mv ./doomsday-linux-amd64 /usr/bin/doomsday

echo "Installing new UAA client."
wget https://github.com/cloudfoundry-incubator/uaa-cli/releases/download/0.10.0/uaa-linux-amd64-0.10.0
mv uaa-linux-amd64-0.10.0 /usr/bin/uaa
chmod a+x /usr/bin/uaa

echo "Installing grype cli"
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

echo "UA hardening"
usg fix cis_level1_server

echo "Cleaning up ua"
apt-get purge --auto-remove -y \
  ubuntu-advantage-tools && \
  rm -rf /var/lib/apt/lists/*
