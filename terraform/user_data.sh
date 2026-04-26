#!/bin/bash
set -e

exec > /var/log/user-data.log 2>&1

dnf update -y
dnf install -y docker

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

docker network create visitor-counter-net || true

docker pull ${dockerhub_user}/visitor-counter-backend:${image_version}

docker rm -f backend || true

docker run -d \
  --name backend \
  --network visitor-counter-net \
  --restart unless-stopped \
  -e REDIS_HOST=${redis_host} \
  -e REDIS_PORT=6379 \
  -e REDIS_SSL=true \
  -p 80:5000 \
  ${dockerhub_user}/visitor-counter-backend:${image_version}