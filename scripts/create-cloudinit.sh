#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config/config.sh"

VM_NAME="$1"

SSH_KEY=$(cat ~/.ssh/id_ed25519.pub)

WORKDIR=$(mktemp -d)

cat > "${WORKDIR}/user-data" <<EOF
#cloud-config

hostname: ${VM_NAME}

users:
  - default
  - name: devops
    groups: wheel
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${SSH_KEY}

  - name: ansible
    groups: wheel
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${SSH_KEY}

package_update: true

packages:
  - qemu-guest-agent

runcmd:
  - systemctl enable --now qemu-guest-agent
EOF

cat > "${WORKDIR}/meta-data" <<EOF
instance-id: ${VM_NAME}
local-hostname: ${VM_NAME}
EOF

sudo cloud-localds \
"${IMAGE}/${VM_NAME}-seed.iso" \
"${WORKDIR}/user-data" \
"${WORKDIR}/meta-data"

rm -rf "${WORKDIR}"

echo "Cloud-init ISO created."























