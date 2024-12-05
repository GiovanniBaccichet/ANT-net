#!/usr/bin/env bash

# Unblock Wi-Fi and all interfaces
sudo rfkill unblock wifi
sudo rfkill unblock all

# Start monitor mode on each interface
for iface in wlan1 wlan2 wlan3; do
    if sudo airmon-ng start "$iface"; then
        echo "Monitor mode enabled on $iface"
    else
        echo "Failed to enable monitor mode on $iface" >&2
        exit 1
    fi
done
