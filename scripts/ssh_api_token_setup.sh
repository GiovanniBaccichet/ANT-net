#!/usr/bin/env bash

# Define the SSH directory and file paths
SSH_DIR="../ssh"
SSH_PRIVATE_KEY="$SSH_DIR/proxmox_id_rsa"
SSH_PUBLIC_KEY="$SSH_PRIVATE_KEY.pub"

# Prompt the user for Proxmox IP
read -p "[!] Enter Proxmox IP address: " PROXMOX_IP
echo

# Check if the SSH directory exists
if [ ! -d "$SSH_DIR" ]; then
    echo "SSH directory $SSH_DIR does not exist. Creating it now..."
    mkdir -p "$SSH_DIR"
    echo "Generating a new SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_PRIVATE_KEY" -N "" > /dev/null 2>&1
    echo "New SSH key pair generated at $SSH_PRIVATE_KEY."
else
    # Check if both the private and public keys exist
    if [ -f "$SSH_PRIVATE_KEY" ] && [ -f "$SSH_PUBLIC_KEY" ]; then
        # Prompt the user if they want to generate a new key
        read -p "[!] SSH key already exists at $SSH_PRIVATE_KEY. Do you want to generate a new one? (y/n): " generate_new_key

        if [[ "$generate_new_key" =~ ^[Yy]$ ]]; then
            echo "  Removing the old SSH key pair..."
            rm -f "$SSH_PRIVATE_KEY" "$SSH_PUBLIC_KEY"
            echo "  Old SSH key pair removed."
            echo "  Generating a new SSH key pair..."
            ssh-keygen -t rsa -b 4096 -f "$SSH_PRIVATE_KEY" -N "" > /dev/null 2>&1
            echo "  New SSH key pair generated at $SSH_PRIVATE_KEY."
        else
            echo "  Using the existing SSH key at $SSH_PRIVATE_KEY."
        fi
    else
        # If the key files don't exist, generate a new pair
        echo "[!] No SSH key pair found. Generating a new SSH key pair..."
        ssh-keygen -t rsa -b 4096 -f "$SSH_PRIVATE_KEY" -N "" > /dev/null 2>&1
        echo "  New SSH key pair generated at $SSH_PRIVATE_KEY."
    fi
fi

# Copy the SSH key to the Proxmox host
echo
echo "[!] Copying SSH key to Proxmox server..."
echo "  Proxmox root password will be asked"
ssh-copy-id -i "$SSH_PRIVATE_KEY" root@"$PROXMOX_IP" > /dev/null 2>&1

# Wait for the SSH key copy to complete before proceeding
if [ $? -ne 0 ]; then
    echo "Failed to copy SSH key. Please check your connection and try again."
    exit 1
fi

# Prompt the user to disable SSH password authentication
echo
read -p "[!] Do you want to disable SSH password authentication? (y/n): " disable_auth

if [[ "$disable_auth" =~ ^[Yy]$ ]]; then
    echo "  Disabling SSH password authentication..."
    
    # Disable SSH password authentication
    ssh -i "$SSH_PRIVATE_KEY" root@"$PROXMOX_IP" "sed -i 's/^#*PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && systemctl restart sshd"

    echo "  SSH password authentication has been disabled."
else
    echo "  SSH password authentication remains enabled."
fi

# Execute commands on the Proxmox server
output=$(ssh -i "$SSH_PRIVATE_KEY" -T root@"$PROXMOX_IP" << 'EOF'
pveum user add terraform@pve && \
pveum role add Terraform -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify SDN.Use VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt User.Modify" && \
pveum aclmod / -user terraform@pve -role Terraform && \
pveum user token add terraform@pve provider --privsep=0
EOF
)

# Extract the full token ID and value
full_token_id=$(echo "$output" | grep "full-tokenid" | cut -d '│' -f 3 | tr -d ' ')
value=$(echo "$output" | grep "value" | awk -F '│' '{gsub(/ /, "", $3); print $3}' | tr -d '%' | tail -n 1)

# Display the results
echo
echo "[!!!] API Token: ${full_token_id}=${value}"
