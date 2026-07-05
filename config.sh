#!/bin/bash

#VM settings
VM_RAM=4096
VM_CPU=2    
VM_DISK=20

#Network settings
NETWORK=default

#Image
IMAGE="/var/lib/libvirt/images"
BASE_IMAGE="Rocky-9-GenericCloud.latest.x86_64.qcow2"

#VM Names
VMS=(
    rocky-mgmt
    rocky-node1
    rocky-node2
)