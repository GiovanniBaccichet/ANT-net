#!/bin/bash

# Define variables
ZONE_NAME="labnet"
VNET_NAME="labvnet"
SUBNET="10.10.10.0/24"
GATEWAY="10.10.10.1"
DHCP_START=10.10.10.10
DHCP_END=10.10.10.254
BRIDGE="vmbr0"

echo "[!] Installing dnsmasq"
apt install -y dnsmasq && systemctl disable --now dnsmasq

echo "[!] Creating Zone"
pvesh create /cluster/sdn/zones --type simple --zone $ZONE_NAME && \

echo "[!] Creating Virtual Network"
pvesh create /cluster/sdn/vnets --vnet $VNET_NAME --zone $ZONE_NAME && \

echo "[!] Creating Subnet for Virtual Netwok"
pvesh create /cluster/sdn/vnets/labvnet/subnets --subnet $SUBNET --type "subnet" --gateway $GATEWAY --snat true --dhcp-range start-address=$DHCP_START,end-address=$DHCP_END && \

echo "[!] Reloading..."
pvesh set /cluster/sdn