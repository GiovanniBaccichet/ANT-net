#!/usr/bin/env bash

sudo sed -i '/eth0:/a\    ens16f0:\n      dhcp4: true' /etc/netplan/50-cloud-init.yaml && \
sudo netplan apply && \
sudo ip route add 10.10.10.0/24 dev eth0