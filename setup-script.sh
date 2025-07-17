#!/bin/bash
# Update package list and install Apache
sudo apt-get update -y
sudo apt-get install -y apache2

# Enable and start Apache
sudo systemctl enable apache2
sudo systemctl start apache2