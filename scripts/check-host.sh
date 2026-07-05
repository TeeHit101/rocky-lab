#!/bin/bash

set -e

echo "Checking virtualization"

virsh version

echo
echo "Checking default network"

virsh net-list --all

echo
echo "Checking base images"

ls -lh /var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2

echo
echo "Host OK"
