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

echo "Updating system timezone"
ln -sf "/usr/share/zoneinfo/$SYSTEM_TIMEZONE" /etc/localtime

apt-get update
apt-get -y -q install \
  ubuntu-advantage-tools ca-certificates \
  tzdata \

echo "Updating system timezone"
ln -sf "/usr/share/zoneinfo/$SYSTEM_TIMEZONE" /etc/localtime

echo "UA attaching"
ua attach --attach-config ua-attach-config.yaml

apt-get -y -q install \
  usg \

echo "Installing grype cli"
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

echo "UA hardening"
usg fix cis_level1_server

echo "Cleaning up ua"
apt-get purge --auto-remove -y \
  ubuntu-advantage-tools && \
  rm -rf /var/lib/apt/lists/*