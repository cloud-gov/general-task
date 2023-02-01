#!/bin/bash

set -e

echo "Configuring ua attach config"
cat <<EOF >> ua-attach-config.yaml
token: $TOKEN
enable_services:
- cis
- esm-infra

EOF

apt-get update
apt-get -y -q install \
  ubuntu-advantage-tools ca-certificates \

echo "UA attaching"
ua attach --attach-config ua-attach-config.yaml

echo "Installing grype cli"
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

echo "UA hardening"
/usr/share/ubuntu-scap-security-guides/cis-hardening/Canonical_Ubuntu_18.04_CIS-harden.sh lvl1_server


echo "Cleaning up ua"
apt-get purge --auto-remove -y \
  ubuntu-advantage-tools && \
  rm -rf /var/lib/apt/lists/*