#!/usr/bin/env bash

sleep 120 && \

qm set 110 -hostpci0 0000:04:00.0 && \

qm stop 110 && \

sleep 30 && \

qm start 110 && \

sleep 300 && \

qm guest exec 110 -- bash -c 'echo -e "network:\n  version: 2\n  renderer: networkd\n  ethernets:\n    ens16:\n      dhcp4: true" | sudo tee /etc/netplan/99_config.yaml > /dev/null && sudo netplan apply' && \

sleep 10 && \

qm guest exec 110 -- bash -c 'sudo apt-get update -y && sudo apt install wireguard-tools net-tools --no-install-recommends -y && git clone https://github.com/donaldzou/WGDashboard.git && cd ./WGDashboard/src && chmod +x ./wgd.sh && ./wgd.sh install && sudo echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sudo sysctl -p /etc/sysctl.conf && sudo iptables -A FORWARD -i wg0 -o eth0 -j ACCEPT && sudo iptables -A FORWARD -i eth0 -o wg0 -m state --state ESTABLISHED,RELATED -j ACCEPT && sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE && ./wgd.sh start' && \

echo "Done"

