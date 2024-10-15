#!/usr/bin/env bash

# Prompt the user for Proxmox IP
read -p "Enter Proxmox IP address: " PROXMOX_IP
echo

# Generate an SSH key
mkdir -p ../ssh
SSH_KEY_PATH="../ssh/proxmox_id_rsa"
ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N ""  > /dev/null 2>&1

# Copy the SSH key to the Proxmox host
echo "Copying SSH key to Proxmox server..."
echo
echo "[!] Proxmox root password will be asked"
ssh-copy-id -i "$SSH_KEY_PATH.pub" root@"$PROXMOX_IP" > /dev/null 2>&1

# Wait for the SSH key copy to complete before proceeding
if [ $? -ne 0 ]; then
    echo "Failed to copy SSH key. Please check your connection and try again."
    exit 1
fi

# Execute commands on the Proxmox server
output=$(ssh -i "$SSH_KEY_PATH" -T root@"$PROXMOX_IP" << 'EOF'
pveum user add terraform10@pve && \
pveum role add Terraform10 -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify SDN.Use VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt User.Modify" && \
pveum aclmod / -user terraform10@pve -role Terraform6 && \
pveum user token add terraform10@pve provider --privsep=0
EOF
)

# Extract the full token ID and value
full_token_id=$(echo "$output" | grep "full-tokenid" | cut -d '│' -f 3 | tr -d ' ')
value=$(echo "$output" | grep "value" | awk -F '│' '{gsub(/ /, "", $3); print $3}' | tr -d '%' | tail -n 1)

# Display the results
echo
echo "[!!!] API Token: ${full_token_id}=${value}"

# Clean up the generated SSH key (optional)
# rm "$SSH_KEY_PATH" "$SSH_KEY_PATH.pub"
