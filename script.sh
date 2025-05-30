#!/bin/bash
# Ensure system is up-to-date
sudo yum update -y

# Install dependencies
sudo yum install -y git yum-utils zip

# Add Docker repository and install Docker
# Check if Docker is already installed
if ! command -v docker &> /dev/null
then
    echo "Docker not found, installing..."
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io
else
    echo "Docker is already installed."
fi
sudo systemctl start docker
sudo systemctl enable docker # Ensure Docker starts on boot

# Create a Docker volume for Jenkins home, if it doesn't exist, to persist data
sudo docker volume inspect jenkins_home > /dev/null 2>&1 || sudo docker volume create jenkins_home

# Stop and remove existing Jenkins container if it exists, to allow update/recreation
if [ "$(sudo docker ps -q -f name=jenkins)" ]; then
    echo "Stopping existing Jenkins container..."
    sudo docker stop jenkins
fi
if [ "$(sudo docker ps -aq -f name=jenkins)" ]; then
    echo "Removing existing Jenkins container..."
    sudo docker rm jenkins
fi

# Run the new Jenkins container
DOCKER_SOCKET="/var/run/docker.sock"
DOCKER_GROUP_ID=$(getent group docker | cut -d: -f3)

sudo docker run --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -d \
  -v jenkins_home:/var/jenkins_home \
  -v ${DOCKER_SOCKET}:${DOCKER_SOCKET} \
  --group-add ${DOCKER_GROUP_ID} \
  jenkins/jenkins:latest

echo "Jenkins setup complete. Jenkins should be accessible on port 8080."
echo "Initial admin password can be found by running: sudo docker logs jenkins"
exit 0
