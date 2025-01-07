#!/bin/bash

# Variables
STATIC_IP="localhost"

# Update and install required packages
apt-get update -y
apt-get install -y docker.io docker-compose ufw

# Configure firewall
ufw allow 22/tcp
ufw allow 8065/tcp
ufw --force enable

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Create Mattermost directory and navigate to it
mkdir -p /opt/mattermost
cd /opt/mattermost

# Create Docker Compose file
cat <<EOF > docker-compose.yml
version: '3.7'
services:
  db:
    image: postgres:12-alpine
    restart: unless-stopped
    volumes:
      - ./volumes/db-volume:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=mmuser
      - POSTGRES_PASSWORD=mostest
      - POSTGRES_DB=mattermost
    networks:
      - mm-network

  app:
    image: mattermost/mattermost-team-edition:latest
    restart: unless-stopped
    ports:
      - "8065:8065"
    volumes:
      - ./volumes/app/mattermost:/mattermost/data
    environment:
      - MM_SQLSETTINGS_DRIVERNAME=postgres
      - MM_SQLSETTINGS_DATASOURCE=postgres://mmuser:mostest@db:5432/mattermost?sslmode=disable
      - MM_SERVICESETTINGS_SITEURL=http://${STATIC_IP}:8065
    depends_on:
      - db
    networks:
      - mm-network

networks:
  mm-network:
    driver: bridge
EOF

# Create required directories
mkdir -p ./volumes/db-volume
mkdir -p ./volumes/app/mattermost
chown -R 2000:2000 ./volumes/app/mattermost

# Start Mattermost
docker-compose up -d

# Verify deployment
echo "Waiting for services to start..."
sleep 30

# Check if services are running
if ! docker-compose ps | grep -q "Up"; then
    echo "Error: Mattermost services failed to start"
    docker-compose logs
    exit 1
fi

# Display service status
echo "Service Status:"
docker-compose ps

# Display success message
echo "============================================"
echo "Mattermost deployment completed successfully!"
echo "Access your Mattermost instance at: http://${STATIC_IP}:8065"
echo "============================================"

# Display initial setup instructions
echo "
Initial Setup Instructions:
1. Visit http://${STATIC_IP}:8065 in your browser
2. Create the first admin account
3. Configure your team settings
4. Invite team members

Note: For production use, consider:
- Changing default database password
- Setting up SSL/TLS
- Configuring email notifications
- Setting up regular backups
"

# Display logs if needed
echo "To view logs, use: docker-compose logs"
