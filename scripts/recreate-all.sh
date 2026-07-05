#!/usr/bin/env bash

# This script destroys, undefines, and recreates all lab VMs.
# It should be run with sudo because it writes to /var/lib/libvirt/images.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config/config.sh"

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo (e.g. sudo $0)" >&2
  exit 1
fi

echo "=== Starting recreation of all lab VMs ==="

for VM_NAME in "${VMS[@]}"; do
  echo "--- Processing VM: $VM_NAME ---"
  
  # Destroy and undefine existing VM if it exists
  if virsh dominfo "$VM_NAME" &>/dev/null; then
    echo "Destroying and undefining existing VM..."
    virsh destroy "$VM_NAME" &>/dev/null || true
    virsh undefine "$VM_NAME" --remove-all-storage --nvram &>/dev/null || true
  fi

  # Recreate disk
  "${SCRIPT_DIR}/create-vm.sh" "$VM_NAME"
  
  # Recreate cloud-init ISO
  "${SCRIPT_DIR}/create-cloudinit.sh" "$VM_NAME"
  
  # Install/import VM
  "${SCRIPT_DIR}/install-vm.sh" "$VM_NAME"
  
  echo "VM $VM_NAME created and imported."
done

echo "=== All VMs successfully created! ==="
echo "Wait 30-60 seconds for them to boot and run: virsh net-dhcp-leases default"
