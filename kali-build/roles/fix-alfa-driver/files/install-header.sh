#!/bin/bash

available_headers=$(apt-cache search linux-headers | grep -Eo 'linux-headers-[0-9]+\.[0-9]+\.[0-9]+-amd64')
selected_headers=$(echo "$available_headers" | head -n 1)
apt install -y "$selected_headers"
