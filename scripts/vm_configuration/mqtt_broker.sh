#!/usr/bin/env bash

sleep 40

qm guest exec 111 -- bash -c 'sudo apt-get update' && \

qm guest exec 111 -- bash -c 'sudo killall apt apt-get && curl -s https://assets.emqx.com/scripts/install-emqx-deb.sh | sudo bash' && \

qm guest exec 111 -- bash -c 'sudo apt-get update && sudo apt-get install -y emqx' && \

qm guest exec 111 -- bash -c 'sudo systemctl start emqx' && \

qm guest exec 111 -- bash -c 'sudo systemctl enable emqx'