#!/bin/bash

# Exit on error
set -e

echo "Starting Chatwoot installation..."

# Update the package lists to ensure access to the latest versions
sudo apt-get update -y
sudo apt-get upgrade -y

# Install required packages: Docker and Docker Compose
sudo apt-get install -y docker.io docker-compose

# Start Docker and enable it to start at boot
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group
sudo usermod -aG docker $USER

# Create a directory for Chatwoot
sudo mkdir -p /home/ubuntu/chatwoot
cd /home/ubuntu/chatwoot

# Generate secure passwords
DB_PASSWORD=$(openssl rand -base64 32)
SECRET_KEY=$(openssl rand -hex 64)

# Create a Docker Compose file for Chatwoot
cat <<EOF > docker-compose.yml
version: '3'

services:
  postgres:
    image: postgres:12
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: chatwoot_production
      POSTGRES_USER: chatwoot
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U chatwoot"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  redis:
    image: redis:6
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  chatwoot:
    image: chatwoot/chatwoot:latest
    depends_on:
      - postgres
      - redis
    ports:
      - "3000:3000"
    environment:
      RAILS_ENV: production
      NODE_ENV: production
      INSTALLATION_ENV: docker
      POSTGRES_HOST: postgres
      POSTGRES_DATABASE: chatwoot_production
      POSTGRES_USERNAME: chatwoot
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      REDIS_URL: redis://redis:6379/0
      SECRET_KEY_BASE: ${SECRET_KEY}
      RAILS_LOG_TO_STDOUT: "true"
    command: bundle exec rails s -b 0.0.0.0
    restart: unless-stopped
    volumes:
      - ./storage:/app/storage

volumes:
  postgres_data:
  redis_data:
  storage:
EOF

# Set correct permissions
sudo chown -R ubuntu:ubuntu /home/ubuntu/chatwoot

# Pull the latest images
sudo docker-compose pull

# Run Docker Compose to start Chatwoot
sudo docker-compose up -d

# Wait for the services to start
echo "Waiting for services to start..."
sleep 30

# Show the logs
echo "Checking logs..."
sudo docker-compose logs chatwoot

echo "Installation completed!"
echo "Please wait a few minutes for all services to fully initialize."
echo "Chatwoot will be available at http://YOUR_IP:3000"
echo "Check logs with: docker-compose logs -f"

# Save the database password to a secure file
echo "Database Password: ${DB_PASSWORD}" > /home/ubuntu/chatwoot/credentials.txt
chmod 600 /home/ubuntu/chatwoot/credentials.txt

# Initialize the database
echo "Initializing database..."
sudo docker-compose exec -T chatwoot bundle exec rails db:chatwoot_prepare
