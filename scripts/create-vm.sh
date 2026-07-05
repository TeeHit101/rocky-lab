#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config/config.sh"

VM_NAME="$1"

echo "Creating disk for ${VM_NAME}..."

qemu-img create \
    -f qcow2 \
    -F qcow2 \
    -b "${IMAGE}/${BASE_IMAGE}" \
    "${IMAGE}/${VM_NAME}.qcow2" \
    "${VM_DISK}G"

echo "Disk created."













    
    

















