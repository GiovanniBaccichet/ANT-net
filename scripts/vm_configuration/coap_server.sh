#!/usr/bin/env bash

sleep 200

qm guest exec 112 -- bash -c '
    sudo apt-get update -y && \
    git clone https://github.com/fpalmese/IoT2023 /home/antlab/IoT && \
    sudo apt-get install -y python3-pip && \
    sudo pip3 install --break-system-packages --quiet CoAPthon3 && \
    python3 /home/antlab/IoT/CoAPServer/coapserver.py
'