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

#install postgres apt repo
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
apt-get update

echo "Updating system timezone"
ln -sf "/usr/share/zoneinfo/$SYSTEM_TIMEZONE" /etc/localtime

#installs yq
wget "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64.tar.gz"
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
  python3-venv

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

#install nodejs using nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

cat <<EOF >> ~/.profile
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF

nvm install $NODE_VERSION

# Install Ruby using rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cat <<EOF >> ~/.profile
export PATH="~/.rbenv/bin:$PATH"
export PATH="~/.rbenv/shims:$PATH"
eval "$(rbenv init -)"
EOF
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

rbenv install $RUBY_CMD_VERSION
rbenv global $RUBY_CMD_VERSION
rbenv shell $RUBY_CMD_VERSION

update-ca-certificates

echo "Installing Spruce version ${SPRUCE_RELEASE_VERSION}"
wget -L -O /usr/local/bin/spruce "https://github.com/geofffranks/spruce/releases/download/v$SPRUCE_RELEASE_VERSION/spruce-linux-amd64"
chmod +x /usr/local/bin/spruce

echo "Installing jq version ${JQ_RELEASE_VERSION}"
wget -L -O /usr/local/bin/jq "https://github.com/jqlang/jq/releases/download/jq-$JQ_RELEASE_VERSION/jq-linux-amd64"
chmod +x /usr/local/bin/jq

echo "Installing terraform version ${TERRAFORM_TEST_RELEASE_VERSION} "
wget -L -O terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_TEST_RELEASE_VERSION}/terraform_${TERRAFORM_TEST_RELEASE_VERSION}_linux_amd64.zip"
unzip -d /usr/local/bin terraform.zip
mv /usr/local/bin/terraform /usr/local/bin/terratest-1.1
rm -f terraform.zip

echo "Installing terraform version ${TERRAFORM_RELEASE_VERSION} "
wget -L -O terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_RELEASE_VERSION}/terraform_${TERRAFORM_RELEASE_VERSION}_linux_amd64.zip"
unzip -d /usr/local/bin terraform.zip
rm -f terraform.zip

echo "Installing CF Client version 7 ${CF_CLI_RELEASE_VERSION7}"
curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&version=${CF_CLI_RELEASE_VERSION7}" | tar -zx -C /usr/local/bin
mv /usr/local/bin/cf7 /usr/local/bin/cf

echo "Installing Credhub Client version ${CREDHUB_CLI_RELEASE_VERSION}"
curl -L "https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_CLI_RELEASE_VERSION}/credhub-linux-amd64-${CREDHUB_CLI_RELEASE_VERSION}.tgz" | tar -zx -C /usr/local/bin

# Install uaac gem
echo "Installing uaac"
gem install cf-uaac -v "$UAAC_CLI_GEM_VERSION" --no-document

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
wget https://github.com/cloud-gov/cg-doomsday/releases/download/1.0.0/doomsday-linux-amd64
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

rm -rf /var/lib/apt/lists/*
