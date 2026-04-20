#!/bin/bash
set -e

dnf update -y
dnf install -y docker

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

cd /home/ec2-user
mkdir -p visitor-counter
cd visitor-counter

cat <<EOF > docker-compose.prod.yml
version: "3.9"

services:
  redis:
    image: redis:7-alpine
    container_name: redis
    restart: unless-stopped
    volumes:
      - redis_data:/data

  backend:
    image: ${dockerhub_user}/visitor-counter-backend:${image_version}
    container_name: backend
    restart: unless-stopped
    depends_on:
      - redis
    environment:
      REDIS_HOST: redis
      REDIS_PORT: 6379
    ports:
      - "80:5000"

volumes:
  redis_data:
EOF

docker network create visitor-counter-net || true
docker volume create redis_data || true

docker pull redis:7-alpine
docker pull ${dockerhub_user}/visitor-counter-backend:${image_version}

docker rm -f redis backend || true

docker run -d \
  --name redis \
  --network visitor-counter-net \
  --restart unless-stopped \
  -v redis_data:/data \
  redis:7-alpine

docker run -d \
  --name backend \
  --network visitor-counter-net \
  --restart unless-stopped \
  -e REDIS_HOST=redis \
  -e REDIS_PORT=6379 \
  -p 80:5000 \
  ${dockerhub_user}/visitor-counter-backend:${image_version}