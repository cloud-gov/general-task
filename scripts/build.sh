#!/bin/bash

set -e

#
# Source configuration environment variables
#
source ./config.sh

apt-get update
apt-get -y upgrade
apt-get -qq -y install --no-install-recommends \
  apt-utils \
  gnupg2 \
  tzdata \
  wget \
  curl \
  ca-certificates

# install postgres apt repo
install -d /usr/share/postgresql-common/pgdg
curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
. /etc/os-release
sh -c "echo 'deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $VERSION_CODENAME-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
# install trivy apt repo
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | tee -a /etc/apt/sources.list.d/trivy.list
apt-get update

echo "Updating system timezone"
ln -sf "/usr/share/zoneinfo/$SYSTEM_TIMEZONE" /etc/localtime

#installs yq
wget -q "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64.tar.gz"
tar xaf yq_linux_amd64.tar.gz
mv yq_linux_amd64 /usr/bin/yq
chmod root:root /usr/bin/yq
rm -f yq_linux_amd64.tar.gz yq.1 install-man-page.sh

echo "Installing basic libraries and development utilities"
apt-get -qq -y install --no-install-recommends \
  build-essential \
  zlib1g-dev \
  cmake \
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
  openssh-client \
  trivy

# symlink python to python3 executable
ln -s "$(which python3)" /usr/bin/python

#upgrade pip and install necessary packages
echo "Upgrading python packages"
pip3 install -q --upgrade pip
pip3 install -q -U \
  setuptools \
  wheel \
  oauthlib \
  pyopenssl \
  pyyaml \
  PyJWT \
  cryptography \
  pipenv \
  awscli

#install nodejs using binary
wget -q "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz"
mkdir -p /usr/local/lib/nodejs
tar -xJf node-v${NODE_VERSION}-linux-x64.tar.xz -C /usr/local/lib/nodejs
ln -s /usr/local/lib/nodejs/node-v${NODE_VERSION}-linux-x64/bin/node /usr/bin/node
ln -s /usr/local/lib/nodejs/node-v${NODE_VERSION}-linux-x64/bin/npm /usr/bin/npm
ln -s /usr/local/lib/nodejs/node-v${NODE_VERSION}-linux-x64/bin/npx /usr/bin/npx
rm -f "node-v${NODE_VERSION}-linux-x64.tar.xz"

#install nvm for other node versions
curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
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

# Install Ruby from source
wget -q "https://cache.ruby-lang.org/pub/ruby/3.4/ruby-${RUBY_RELEASE_VERSION}.tar.gz"
tar xaf "ruby-${RUBY_RELEASE_VERSION}.tar.gz"
pushd "ruby-${RUBY_RELEASE_VERSION}"
  ./configure -q
  make -s -j $(nproc)
  make -s install
popd
rm -f "ruby-${RUBY_RELEASE_VERSION}.tar.gz"
rm -rf "ruby-${RUBY_RELEASE_VERSION}"

#update to latest rubygems
gem update --system -q --silent

# Install Bundler
gem install bundler -v $BUNDLER_RELEASE_VERSION --no-document -q --silent

# Install Rake
gem install rake -v $RAKE_RELEASE_VERSION --no-document -q --silent

# Install RDoc
gem install rdoc -v $RDOC_RELEASE_VERSION -q --silent

# Install CGI
gem install cgi -v $CGI_RELEASE_VERSION -q --silent

#Install rexml
gem install rexml -v $REXML_RELEASE_VERSION -q --silent

# Install uaac gem
gem install cf-uaac -v $UAAC_CLI_GEM_VERSION -q --silent

update-ca-certificates

echo "Installing Spruce"
wget -q -L -O /usr/local/bin/spruce "https://github.com/geofffranks/spruce/releases/latest/download/spruce-linux-amd64"
chmod +x /usr/local/bin/spruce

echo "Installing jq"
wget -q -L -O /usr/local/bin/jq "https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64"
chmod +x /usr/local/bin/jq

echo "Installing terraform version ${TERRAFORM_TEST_RELEASE_VERSION} "
wget -q -L -O terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_TEST_RELEASE_VERSION}/terraform_${TERRAFORM_TEST_RELEASE_VERSION}_linux_amd64.zip"
unzip -qq -d /usr/local/bin terraform.zip terraform
mv /usr/local/bin/terraform /usr/local/bin/terratest-1.1
rm -f terraform.zip
rm -f /usr/local/bin/LICENSE.txt

echo "Installing terraform version ${TERRAFORM_RELEASE_VERSION} "
wget -q -L -O terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_RELEASE_VERSION}/terraform_${TERRAFORM_RELEASE_VERSION}_linux_amd64.zip"
unzip -qq -d /usr/local/bin terraform.zip terraform
rm -f terraform.zip

echo "Installing CF Client version 7 ${CF_CLI_RELEASE_VERSION7}"
curl -s -L "https://cli.run.pivotal.io/stable?release=linux64-binary&version=${CF_CLI_RELEASE_VERSION7}" | tar -zx -C /usr/local/bin
chmod root:root /usr/local/bin/cf7

echo "Installing CF Client version 8 ${CF_CLI_RELEASE_VERSION8}"
curl -s -L "https://cli.run.pivotal.io/stable?release=linux64-binary&version=${CF_CLI_RELEASE_VERSION8}" | tar -zx -C /usr/local/bin
mv /usr/local/bin/cf8 /usr/local/bin/cf
chmod root:root /usr/local/bin/cf

#cleanup cf files
rm -f /usr/local/bin/LICENSE /usr/local/bin/NOTICE

echo "Installing Credhub Client version ${CREDHUB_CLI_RELEASE_VERSION}"
curl -s -L "https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_CLI_RELEASE_VERSION}/credhub-linux-amd64-${CREDHUB_CLI_RELEASE_VERSION}.tgz" | tar -zx -C /usr/local/bin

echo "Installing BOSH CLI v2 version ${BOSH_CLI_V2_RELEASE_VERSION}"
curl -s -L -o /usr/local/bin/bosh "https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_CLI_V2_RELEASE_VERSION}/bosh-cli-${BOSH_CLI_V2_RELEASE_VERSION}-linux-amd64"

chmod +x /usr/local/bin/bosh
ln -s /usr/local/bin/bosh /usr/local/bin/bosh2
ln -s /usr/local/bin/bosh /usr/local/bin/bosh-cli

echo "Installing Go"
curl -s -OL "https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz"
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
wget -q https://github.com/cloud-gov/cg-doomsday/releases/latest/download/doomsday-linux-amd64
chmod a+x doomsday-linux-amd64
mv ./doomsday-linux-amd64 /usr/bin/doomsday

echo "Installing new UAA client."
wget -q https://github.com/cloudfoundry/uaa-cli/releases/download/${UAA_CLIENT_VERSION}/uaa-linux-amd64-${UAA_CLIENT_VERSION}
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
apt -qq install gh -y

echo "Installing grype cli"
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

echo "Installing Alertmanager CLI"
go install github.com/prometheus/alertmanager/cmd/amtool@latest

rm -rf /var/lib/apt/lists/*

#cleanup go cache
go clean -cache
go clean -modcache
