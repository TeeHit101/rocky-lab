#!/usr/bin/env bash

# This script destroys and deletes all VMs defined in the configuration.
# It should be run with sudo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config/config.sh"

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo (e.g. sudo $0)" >&2
  exit 1
fi

echo "=== Starting deletion of all lab VMs ==="

for VM_NAME in "${VMS[@]}"; do
  "${SCRIPT_DIR}/delete-vm.sh" "$VM_NAME"
done

echo "=== All VMs successfully deleted! ==="
