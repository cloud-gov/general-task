#!/bin/bash

set -e

#
# Source configuration environment variables
#
source ./config.sh

apt-get update
apt-get -y upgrade
apt-get -y -q install --no-install-recommends \
  apt-utils \
  gnupg2 \
  tzdata \
  wget \
  lsb-release \
  ca-certificates

apt-get clean

# install postgres apt repo
RELEASE=$(lsb_release -cs)
echo "deb http://apt.postgresql.org/pub/repos/apt/ $RELEASE-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
apt-get update

echo "Updating system timezone"
ln -sf "/usr/share/zoneinfo/$SYSTEM_TIMEZONE" /etc/localtime

#installs yq
wget "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64.tar.gz"
tar xvaf yq_linux_amd64.tar.gz
mv yq_linux_amd64 /usr/bin/yq
rm -f yq_linux_amd64.tar.gz yq.1 install-man-page.sh

echo "Installing basic libraries and development utilities"
apt-get -y -q install --no-install-recommends \
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
  libffi-dev \
  python3-pip \
  python3-venv \
  python3-dev \
  openssh-client

apt-get clean

# symlink python to python3 executable
ln -s "$(which python3)" /usr/bin/python

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

#install nodejs using binary
wget "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz"
mkdir -p /usr/local/lib/nodejs
tar -xJvf node-v${NODE_VERSION}-linux-x64.tar.xz -C /usr/local/lib/nodejs
ln -s /usr/local/lib/nodejs/node-v${NODE_VERSION}-linux-x64/bin/node /usr/bin/node
ln -s /usr/local/lib/nodejs/node-v${NODE_VERSION}-linux-x64/bin/npm /usr/bin/npm
ln -s /usr/local/lib/nodejs/node-v${NODE_VERSION}-linux-x64/bin/npx /usr/bin/npx
rm -f "node-v${NODE_VERSION}-linux-x64.tar.xz"

#install nvm for other node versions
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# N.b, adding to .profile so it's somewhere _moderately_ obvious,
# but concourse doesn't run interactive shells so using nvm requires
# manually sourcing .profile in your pipeline config
cat <<EOF >> ~/.profile
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF

nvm install $NODE_VERSION

# Install Ruby from source
wget "https://cache.ruby-lang.org/pub/ruby/3.3/ruby-${RUBY_RELEASE_VERSION}.tar.gz"
tar xvaf "ruby-${RUBY_RELEASE_VERSION}.tar.gz"
pushd "ruby-${RUBY_RELEASE_VERSION}"
  ./configure
  make -j4
  make install
popd
rm -f "ruby-${RUBY_RELEASE_VERSION}.tar.gz"
rm -rf "ruby-${RUBY_RELEASE_VERSION}"

#update to latest rubygems
gem update --system

# Install Bundler
gem install bundler -v $BUNDLER_RELEASE_VERSION --no-document

# Install Rake
gem install rake -v $RAKE_RELEASE_VERSION --no-document

# Install RDoc
gem install rdoc -v $RDOC_RELEASE_VERSION

# Install CGI
gem install cgi -v $CGI_RELEASE_VERSION

#Install rexml
gem install rexml -v $REXML_RELEASE_VERSION

# Install uaac gem
gem install cf-uaac -v $UAAC_CLI_GEM_VERSION

update-ca-certificates

echo "Installing Spruce"
wget -L -O /usr/local/bin/spruce "https://github.com/geofffranks/spruce/releases/latest/download/spruce-linux-amd64"
chmod +x /usr/local/bin/spruce

echo "Installing jq"
wget -L -O /usr/local/bin/jq "https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64"
chmod +x /usr/local/bin/jq

echo "Installing terraform version ${TERRAFORM_TEST_RELEASE_VERSION} "
wget -L -O terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_TEST_RELEASE_VERSION}/terraform_${TERRAFORM_TEST_RELEASE_VERSION}_linux_amd64.zip"
unzip -d /usr/local/bin terraform.zip terraform
mv /usr/local/bin/terraform /usr/local/bin/terratest-1.1
rm -f terraform.zip
rm -f /usr/local/bin/LICENSE.txt

echo "Installing terraform version ${TERRAFORM_RELEASE_VERSION} "
wget -L -O terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_RELEASE_VERSION}/terraform_${TERRAFORM_RELEASE_VERSION}_linux_amd64.zip"
unzip -d /usr/local/bin terraform.zip terraform
rm -f terraform.zip

echo "Installing CF Client version 7 ${CF_CLI_RELEASE_VERSION7}"
curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&version=${CF_CLI_RELEASE_VERSION7}" | tar -zx -C /usr/local/bin
mv /usr/local/bin/cf7 /usr/local/bin/cf

echo "Installing Credhub Client version ${CREDHUB_CLI_RELEASE_VERSION}"
curl -L "https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_CLI_RELEASE_VERSION}/credhub-linux-amd64-${CREDHUB_CLI_RELEASE_VERSION}.tgz" | tar -zx -C /usr/local/bin

echo "Installing BOSH CLI v2 version ${BOSH_CLI_V2_RELEASE_VERSION}"
curl -L -o /usr/local/bin/bosh "https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_CLI_V2_RELEASE_VERSION}/bosh-cli-${BOSH_CLI_V2_RELEASE_VERSION}-linux-amd64"

chmod +x /usr/local/bin/bosh
ln -s /usr/local/bin/bosh /usr/local/bin/bosh2
ln -s /usr/local/bin/bosh /usr/local/bin/bosh-cli

echo "Installing Go"
curl -OL "https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz"
mkdir -p /usr/local/go
tar -xzf "go$GO_VERSION.linux-amd64.tar.gz" -C /usr/local/go --strip-components=1
ln -s /usr/local/go/bin/go /usr/local/bin/go
ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt
rm go$GO_VERSION.linux-amd64.tar.gz

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
wget https://github.com/cloud-gov/cg-doomsday/releases/latest/download/doomsday-linux-amd64
chmod a+x doomsday-linux-amd64
mv ./doomsday-linux-amd64 /usr/bin/doomsday

echo "Installing new UAA client."
wget https://github.com/cloudfoundry/uaa-cli/releases/download/${UAA_CLIENT_VERSION}/uaa-linux-amd64-${UAA_CLIENT_VERSION}
mv uaa-linux-amd64-${UAA_CLIENT_VERSION} /usr/bin/uaa
chmod a+x /usr/bin/uaa

echo "Installing GitHub CLI"
# # Instructions adapted from: https://github.com/cli/cli/blob/trunk/docs/install_linux.md
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt update
apt install gh -y

echo "Installing grype cli"
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

echo "Installing Alertmanager CLI"
go install github.com/prometheus/alertmanager/cmd/amtool@latest

rm -rf /var/lib/apt/lists/*
