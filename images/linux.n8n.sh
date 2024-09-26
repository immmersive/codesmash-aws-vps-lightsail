#!/bin/bash

# Update and install Docker 
sudo apt-get update -y
apt-get install -y docker.io

# Start Docker and enable it to start at boot
systemctl start docker
systemctl enable docker

# Pull the official n8n Docker image
docker pull n8nio/n8n

# Create the .n8n directory for persistent data
sudo mkdir -p /home/ubuntu/.n8n
sudo chown -R 1000:1000 /home/ubuntu/.n8n
sudo chmod -R 755 /home/ubuntu/.n8n

# Create the /home/node/.n8n directory (in case it's used by n8n)
sudo mkdir -p /home/node/.n8n
sudo chown -R 1000:1000 /home/node/.n8n

# Run n8n on port 5678
docker run -d --name n8n -p 5678:5678 -v /home/ubuntu/.n8n:/home/node/.n8n n8nio/n8n
