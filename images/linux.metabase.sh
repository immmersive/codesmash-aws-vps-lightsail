#!/bin/bash

# Exit on any error
set -e

# Update package lists
echo "Updating package lists..."
apt-get update -y

# Install Docker
echo "Installing Docker..."
apt-get install -y docker.io

# Start Docker and enable it to start at boot
echo "Starting and enabling Docker service..."
systemctl start docker
systemctl enable docker

# Pull Docker images
echo "Pulling Docker images for Metabase and PostgreSQL..."
docker pull metabase/metabase
docker pull postgres

# Create a Docker network
echo "Creating a Docker network for Metabase..."
docker network create metabase-network || echo "Network already exists."

# Create directories for data persistence
echo "Creating directories for data persistence..."
mkdir -p /home/ubuntu/metabase-data
mkdir -p /home/ubuntu/postgres-data

# Ensure Docker is running
if ! systemctl is-active --quiet docker; then
  echo "Docker is not running. Exiting..."
  exit 1
fi

# Stop and remove existing containers (if any)
echo "Cleaning up existing containers..."
docker stop metabase metabaseappdb || true
docker rm metabase metabaseappdb || true

# Run PostgreSQL container
echo "Starting PostgreSQL container..."
docker run -d \
  --name metabaseappdb \
  --network metabase-network \
  -e POSTGRES_DB=metabase \
  -e POSTGRES_USER=metabaseuser \
  -e POSTGRES_PASSWORD=securepassword \
  -v /home/ubuntu/postgres-data:/var/lib/postgresql/data \
  postgres

# Run Metabase container
echo "Starting Metabase container..."
docker run -d \
  --name metabase \
  --network metabase-network \
  -p 3000:3000 \
  -e MB_DB_TYPE=postgres \
  -e MB_DB_DBNAME=metabase \
  -e MB_DB_PORT=5432 \
  -e MB_DB_USER=metabaseuser \
  -e MB_DB_PASS=securepassword \
  -e MB_DB_HOST=metabaseappdb \
  -v /home/ubuntu/metabase-data:/metabase-data \
  metabase/metabase

# Check if ufw is active and open port 3000
if ufw status | grep -qw active; then
  echo "Configuring firewall to allow port 3000..."
  ufw allow 3000
  ufw reload
else
  echo "ufw is not active. Skipping firewall configuration."
fi

echo "Setup complete! Metabase is running on port 3000."
