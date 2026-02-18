#!/bin/bash
# SOS DOCKER NODE SETUP - V15.0
# Deploys SOS Core in a container.

echo ">>> SOS V15: DESKTOP DEPLOYMENT"

if ! command -v docker &> /dev/null
then
    echo ">>> ERROR: Docker not found. Please install Docker Desktop first."
    exit
fi

echo ">>> PULLING RESOURCES..."
# Using a standard PHP-Apache image for simplicity
docker pull php:8.0-apache

echo ">>> CREATING CONTAINER..."
# Binds current dir/src to web root
mkdir -p ~/sos_data
docker run -d -p 8085:80 -v ~/sos_data:/var/www/html --name sos_node php:8.0-apache

echo ">>> INJECTING CORE..."
docker exec sos_node bash -c "apt-get update && apt-get install -y git && git clone https://github.com/ricardosos/sos_core.git /var/www/html"

echo ">>> NODE OPERATIONAL."
echo ">>> ACCESS: http://localhost:8085"
