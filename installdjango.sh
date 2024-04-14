#!/bin/bash

# Update package lists
sudo apt-get update

# Install required packages
sudo apt-get install -y python3 python3-pip apache2

# Install Django using pip3
sudo pip3 install django
