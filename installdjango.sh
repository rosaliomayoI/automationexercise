#!/bin/bash
# Update and upgrade the system
sudo apt-get update
sudo apt-get upgrade -y

# Install Python and pip
sudo apt-get install -y python3-pip python3-dev libpq-dev

# Install Django
sudo pip3 install django

# Create a new Django project
django-admin startproject mydjango

# Change into the project directory and run migrations
cd mydjango
python3 manage.py migrate

# Start the Django development server on all interfaces
nohup python3 manage.py runserver 0.0.0.0:8000 &
