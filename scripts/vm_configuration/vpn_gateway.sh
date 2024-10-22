#!/usr/bin/env bash

qm set 110 -hostpci0 0000:04:00.0

sleep 30

qm guest exec 110 -- bash -c 'echo -e "network:\n  version: 2\n  renderer: networkd\n  ethernets:\n    ens16:\n      dhcp4: true" | sudo tee /etc/netplan/99_config.yaml > /dev/null && sudo netplan apply'

echo "Done"

