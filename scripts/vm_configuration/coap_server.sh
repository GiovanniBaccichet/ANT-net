#!/usr/bin/env bash

sleep 200

qm guest exec 112 -- bash -c '
    sudo apt-get update -y && \
    sudo dpkg --configure -a && \
    sudo apt-get install -y python3-pip && \
    sudo pip3 install CoAPthon3 --break-system-packages && \
    git clone https://github.com/fpalmese/IoT2023 /home/antlab/IoT && \
    python3 /home/antlab/IoT/CoAPServer/coapserver.py
'