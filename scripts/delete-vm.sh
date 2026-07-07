#!/usr/bin/env bash

# This script destroys, undefines, and deletes the storage files for a specific lab VM.
# It should be run with sudo because it interacts with libvirt and deletes files under /var/lib/libvirt/images.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config/config.sh"

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo (e.g. sudo $0)" >&2
  exit 1
fi

if [ $# -lt 1 ]; then
  echo "Usage: $0 <vm-name>" >&2
  exit 1
fi

VM_NAME="$1"

echo "=== Deleting VM: $VM_NAME ==="

# Destroy (stop) VM if it is running
if virsh dominfo "$VM_NAME" &>/dev/null; then
  STATE=$(virsh domstate "$VM_NAME")
  if [ "$STATE" = "running" ]; then
    echo "Stopping VM $VM_NAME..."
    virsh destroy "$VM_NAME" &>/dev/null || true
  fi

  # Undefine VM (including NVRAM and storage volumes registered under domain if any)
  echo "Undefining VM $VM_NAME..."
  virsh undefine "$VM_NAME" --remove-all-storage --nvram &>/dev/null || true
else
  echo "VM $VM_NAME does not exist in libvirt."
fi

# Explicitly clean up leftover disk images if they still exist
VM_DISK_PATH="${IMAGE}/${VM_NAME}.qcow2"
VM_SEED_PATH="${IMAGE}/${VM_NAME}-seed.iso"

if [ -f "$VM_DISK_PATH" ]; then
  echo "Removing disk: $VM_DISK_PATH..."
  rm -f "$VM_DISK_PATH"
fi

if [ -f "$VM_SEED_PATH" ]; then
  echo "Removing seed ISO: $VM_SEED_PATH..."
  rm -f "$VM_SEED_PATH"
fi

echo "=== VM $VM_NAME deleted successfully ==="
