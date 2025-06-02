#!/bin/bash

# Log everything
exec > /var/log/supabase-setup.log 2>&1
set -eu

echo "==== Installing Docker Engine and Compose v2 ===="
apt-get update
apt-get install -y ca-certificates curl gnupg git lsb-release

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

echo "==== Cloning Supabase ===="
cd /home/ubuntu
git clone --depth 1 https://github.com/supabase/supabase || echo "Repo already exists"

echo "==== Preparing supabase-project ===="
mkdir -p /home/ubuntu/supabase-project
cp -rf /home/ubuntu/supabase/docker/* /home/ubuntu/supabase-project/
cp /home/ubuntu/supabase/docker/.env.example /home/ubuntu/supabase-project/.env || echo ".env.example not found"

chown -R ubuntu:ubuntu /home/ubuntu/supabase-project

echo "==== Patching docker-compose.yml to expose port 3000 ===="
sed -i '/container_name: supabase-studio/a\    ports:\n      - "3000:3000"' /home/ubuntu/supabase-project/docker-compose.yml

echo "==== Starting Supabase ===="
cd /home/ubuntu/supabase-project
docker compose up -d

echo "==== Done! Access Supabase Studio at http://<your-public-ip>:3000 ===="
