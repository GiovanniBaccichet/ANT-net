#!/usr/bin/env bash

curl -s https://assets.emqx.com/scripts/install-emqx-deb.sh | sudo bash && \
sudo apt-get install emqx && \
sudo systemctl start emqx && \
sudo emqx start