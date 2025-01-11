#!/bin/bash

# 1. System update
export DEBIAN_FRONTEND=noninteractive
sudo apt update && sudo apt upgrade -y

# 2. SWAP configuration
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# 3. Docker installation
# Install prerequisites
sudo apt install -y ca-certificates curl gnupg

# Set up Docker repository
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker and related packages
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

# Inform user to re-login to apply group changes
echo "Docker group changes applied. If you face issues running Docker commands, please logout and login again."

# 4. bolt-diy setup
mkdir -p $HOME/bolt-diy
cd $HOME/bolt-diy

# Create Dockerfile
cat > Dockerfile << EOL
FROM ubuntu:24.04 as bolt-ai-production

ENV NODE_VERSION=20.x
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_OPTIONS="--max-old-space-size=2048"
ENV HOST=0.0.0.0

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_\${NODE_VERSION} | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g npm@latest \
    && npm install -g pnpm

WORKDIR /app

RUN git clone https://github.com/stackblitz-labs/bolt.diy.git .

RUN echo "OPENAI_API_KEY=dummy\n\
NODE_ENV=production\n\
PORT=5173\n\
VITE_LOG_LEVEL=debug\n\
DEFAULT_NUM_CTX=32768\n\
RUNNING_IN_DOCKER=true" > .env.local

RUN pnpm install

RUN pnpm run build

EXPOSE 5173

CMD ["pnpm", "run", "dockerstart"]
EOL

# Create docker-compose.yml
cat > docker-compose.yml << EOL
services:
  app-prod:
    image: bolt-ai:production
    build:
      context: .
      dockerfile: Dockerfile
      target: bolt-ai-production
    ports:
      - "5173:5173"
    env_file: ".env.local"
    environment:
      - NODE_ENV=production
      - COMPOSE_PROFILES=production
      - PORT=5173
      - RUNNING_IN_DOCKER=true
    extra_hosts:
      - "host.docker.internal:host-gateway"
    command: pnpm run dockerstart
    profiles:
      - production
EOL

# Create .env.local
cat > .env.local << EOL
OPENAI_API_KEY=dummy
NODE_ENV=production
PORT=5173
VITE_LOG_LEVEL=debug
DEFAULT_NUM_CTX=32768
RUNNING_IN_DOCKER=true
EOL

# Build and start containers
docker compose --profile production up -d --build

# Check logs and container status
docker compose logs -f
docker ps

# Final reminder for configuration
echo "Ensure AWS Lightsail firewall allows ports 80, 443, and 5173. Replace 'dummy' in .env.local with your OpenAI API key if required."
