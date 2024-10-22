#!/usr/bin/env bash

# Set variables
IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
IMAGE_NAME="/var/lib/vz/template/iso/noble-server-cloudimg-guest_agent-amd64.img"
VM_ID=9000
MEMORY=4096
N_CORES=4
DISK_SIZE="+16.5G"
STORAGE="local-lvm"
BRIDGE="vmbr0"

# Check if VM ID already exists
if qm status $VM_ID &>/dev/null; then
    echo "VM with ID $VM_ID already exists. Exiting..."
    exit 1
fi

# Install libguestfs-tools on Proxmox server.
apt-get install libguestfs-tools -y && \

# Download Ubuntu cloud image
echo "Downloading Ubuntu cloud image..."
wget $IMAGE_URL -O $IMAGE_NAME &>/dev/null && \
if [ $? -ne 0 ]; then
    echo "Error downloading the image. Exiting..."
    exit 1
fi

# Install qemu-guest-agent on Ubuntu image.
virt-customize -a $IMAGE_NAME --install qemu-guest-agent && \

# Create the VM
echo "Creating VM $VM_ID..."
qm create $VM_ID --memory $MEMORY --name ubuntu-cloud-GA && \
if [ $? -ne 0 ]; then
    echo "Error creating VM $VM_ID. Exiting..."
    exit 1
fi

# Import the disk
echo "Importing disk..."
qm importdisk $VM_ID $IMAGE_NAME $STORAGE && \
if [ $? -ne 0 ]; then
    echo "Error importing disk. Exiting..."
    exit 1
fi

# Configure the VM's hardware
echo "Configuring VM hardware..."
qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 $STORAGE:vm-$VM_ID-disk-0 && \
qm set $VM_ID --ide2 $STORAGE:cloudinit && \
qm set $VM_ID --boot c --bootdisk scsi0 && \
qm set $VM_ID --serial0 socket --vga serial0 && \

# Set the number of CPUs and CPU model
echo "Setting CPU cores and type..."
qm set $VM_ID --cores $N_CORES --cpu x86-64-v2-AES && \
if [ $? -ne 0 ]; then
    echo "Error setting CPU cores and type. Exiting..."
    exit 1
fi

# Resize the disk
echo "Resizing disk by $DISK_SIZE..."
qm resize $VM_ID scsi0 $DISK_SIZE && \
if [ $? -ne 0 ]; then
    echo "Error resizing the disk. Exiting..."
    exit 1
fi

sleep 30 && \

echo "Starting VM"

qm start $VM_ID && \

sleep 360 && \

echo "Shutting down VM"

qm shutdown $VM_ID && \

#Convert the VM to a template
echo "Converting VM $VM_ID to a template..."
qm set $VM_ID --template 1 && \
if [ $? -ne 0 ]; then
    echo "Error converting VM to template. Exiting..."
    exit 1
fi

# Cleanup
echo "Cloud image installation and setup completed for VM $VM_ID."
