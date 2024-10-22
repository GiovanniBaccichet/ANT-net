#!/usr/bin/env bash

sleep 40

qm set 110 -hostpci0 0000:04:00.0

qm stop 110

sleep 10

qm start 110

sleep 60

qm guest exec 110 -- bash -c 'echo -e "network:\n  version: 2\n  renderer: networkd\n  ethernets:\n    ens16:\n      dhcp4: true" | sudo tee /etc/netplan/99_config.yaml > /dev/null && sudo netplan apply'

echo "Done"

