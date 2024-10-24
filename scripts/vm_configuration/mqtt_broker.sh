#!/usr/bin/env bash

# Wait for 40 seconds
sleep 40

# Execute commands inside the guest VM (ID 111) using Proxmox qm guest exec
qm guest exec 111 -- bash -c '
  # Download and install the EMQX deb script
  curl -s https://assets.emqx.com/scripts/install-emqx-deb.sh | sudo bash && \
  sudo apt-get update && \
  
  # Install EMQX
  sudo apt-get install -y emqx && \
  
  # Start and enable the EMQX service
  sudo systemctl start emqx && \
  sudo systemctl enable emqx
'
