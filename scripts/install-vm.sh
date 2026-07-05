#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config/config.sh"

VM_NAME="$1"

echo "Installing VM: $VM_NAME"

virt-install \
  --name "$VM_NAME" \
  --memory "$VM_RAM" \
  --vcpus "$VM_CPU" \
  --disk path="${IMAGE}/${VM_NAME}.qcow2",format=qcow2,bus=virtio \
  --disk path="${IMAGE}/${VM_NAME}-seed.iso",device=cdrom \
  --os-variant rocky9 \
  --import \
  --network network="$NETWORK",model=virtio \
  --boot uefi \
  --graphics none \
  --noautoconsole

echo "VM installed: $VM_NAME"
