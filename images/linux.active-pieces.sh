#!/bin/bash

# Update package lists to ensure access to the latest versions
apt-get update -y

# Install Docker
apt-get install -y docker.io

# Download the latest version of Docker Compose
# The URL is dynamically constructed to fetch the latest release for the current system architecture
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make the Docker Compose binary executable
chmod +x /usr/local/bin/docker-compose

# Start the Docker service
systemctl start docker

# Enable Docker to start automatically at boot time
systemctl enable docker

# Clone the Activepieces repository from GitHub
git clone https://github.com/activepieces/activepieces.git

# Change directory to the cloned Activepieces repository
cd activepieces

# Execute the deployment script provided in the tools directory
sh tools/deploy.sh

# Launch the Docker Compose application with the project name 'activepieces'
docker-compose -p activepieces up

# Open and access on port 8080
