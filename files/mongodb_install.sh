#!/bin/bash
# Instructions from https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/

# Import the public key used by the package management system
# curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
#    sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
#    --dearmor
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | gpg --yes -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor


# Create a list file for MongoDB
# echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-7.0.list


# Reload local package database
apt-get update

