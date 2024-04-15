#!/bin/bash
# Update System
sudo apt-get update
sudo apt-get upgrade -y

# Install Python and Pip
sudo apt-get install python3-pip python3-dev libpq-dev -y

# Install Virtualenv
sudo pip3 install virtualenv

# Create a Virtual Environment and Activate It
virtualenv djangovenv
source djangovenv/bin/activate

# Install Django
pip install django

# Create a new Django project
django-admin startproject myproject

# Change to the project directory
cd myproject

# Run Django migrations to initialize your environment
python manage.py migrate

# OPTIONAL: Setup Django to run on startup
echo "@reboot root /home/$USER/djangovenv/bin/python /home/$USER/myproject/manage.py runserver 0.0.0.0:8000" | sudo tee -a /etc/crontab > /dev/null

