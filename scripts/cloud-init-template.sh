#!/usr/bin/env bash

# Set variables
IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
IMAGE_NAME="noble-server-cloudimg-amd64.img"
VM_ID=9000
MEMORY=4096
DISK_SIZE="+16G"
BRIDGE="labvnet"
STORAGE="local-lvm"

# Install libguestfs-tools on Proxmox server.
apt-get install libguestfs-tools

# Install qemu-guest-agent on Ubuntu image.
virt-customize -a focal-server-cloudimg-amd64.img --install qemu-guest-agent

# Download Ubuntu cloud image
echo "Downloading Ubuntu cloud image..."
wget $IMAGE_URL -O $IMAGE_NAME
if [ $? -ne 0 ]; then
    echo "Error downloading the image. Exiting..."
    exit 1
fi

# Create the VM
echo "Creating VM $VM_ID..."
qm create $VM_ID --memory $MEMORY --name ubuntu-cloud --net0 virtio,bridge=$BRIDGE
if [ $? -ne 0 ]; then
    echo "Error creating VM $VM_ID. Exiting..."
    exit 1
fi

# Import the disk
echo "Importing disk..."
qm importdisk $VM_ID $IMAGE_NAME $STORAGE
if [ $? -ne 0 ]; then
    echo "Error importing disk. Exiting..."
    exit 1
fi

# Configure the VM's hardware
echo "Configuring VM hardware..."
qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 $STORAGE:vm-$VM_ID-disk-0
qm set $VM_ID --ide2 $STORAGE:cloudinit
qm set $VM_ID --boot c --bootdisk scsi0
qm set $VM_ID --serial0 socket --vga serial0

# Resize the disk
echo "Resizing disk by $DISK_SIZE..."
qm resize $VM_ID scsi0 $DISK_SIZE
if [ $? -ne 0 ]; then
    echo "Error resizing the disk. Exiting..."
    exit 1
fi

# Cleanup
echo "Cloud image installation and setup completed for VM $VM_ID."

echo "Converting VM to Template"
qm set $VM_ID --template 1