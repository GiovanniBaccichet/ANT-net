#!/usr/bin/env bash

# Wait 2 minutes before starting actions
sleep 120

# Set the PCI device for VM 110
qm set 110 -hostpci0 0000:04:00.0

# Stop VM 110
qm stop 110

# Wait for 30 seconds before restarting VM
sleep 30

# Start VM 110
qm start 110

# Wait 5 minutes to allow VM to boot up
sleep 300

# Apply network configuration inside VM 110
qm guest exec 110 -- bash -c '
    echo -e "network:\n  version: 2\n  renderer: networkd\n  ethernets:\n    ens16:\n      dhcp4: true" \
    | sudo tee /etc/netplan/99_config.yaml > /dev/null && sudo netplan apply
'

# Wait for 10 seconds
sleep 10

# Install WireGuard and other necessary tools, then configure WGDashboard and network settings
qm guest exec 110 -- bash -c '
    sudo apt-get update -y && \
    sudo apt-get install wireguard-tools net-tools --no-install-recommends -y && \
    git clone https://github.com/donaldzou/WGDashboard.git && \
    cd ./WGDashboard/src && \
    chmod +x ./wgd.sh && \
    ./wgd.sh install && \
    echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf > /dev/null && \
    sudo sysctl -p /etc/sysctl.conf && \
    sudo iptables -A FORWARD -i wg0 -o eth0 -j ACCEPT && \
    sudo iptables -A FORWARD -i eth0 -o wg0 -m state --state ESTABLISHED,RELATED -j ACCEPT && \
    sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE && \
    ./wgd.sh start
'

# Print completion message
echo "Done"
