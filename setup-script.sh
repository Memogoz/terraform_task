#!/bin/bash
# Update package list and install Apache
sudo apt-get update -y
sudo apt-get install -y apache2

# Enable and start Apache
sudo systemctl enable apache2
sudo systemctl start apache2

# Get the instance's local IP address using IMDSv2
# First, get a session token
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
# Then, use the token to get the IP address
IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

# Write the IP address to the default web page
echo "<html><body><h1>Host IP: $IP</h1></body></html>" | sudo tee /var/www/html/index.html