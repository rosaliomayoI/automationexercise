
#!/bin/bash

# Update and upgrade the system
sudo apt-get update && sudo apt-get upgrade -y

# Install Python3, pip, and other necessary packages
sudo apt-get install -y python3 python3-pip python3-venv

# Set up a virtual environment for the Django project
mkdir ~/django_project
cd ~/django_project
python3 -m venv venv
source venv/bin/activate

# Install Django
pip install django

# Create a new Django project
django-admin startproject myproject .

# Apply migrations and start the Django development server on all interfaces
python manage.py migrate
python manage.py runserver 0.0.0.0:8000 &
