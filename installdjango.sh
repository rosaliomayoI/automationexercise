#!/bin/bash

# Update package lists
sudo apt-get update

# Install required packages
sudo apt-get install -y python3 python3-pip apache2

# Install mod_wsgi
sudo apt-get install -y libapache2-mod-wsgi-py3

# Install Django using pip3
sudo pip3 install django

# Setup a Django project (modify 'myproject' to your desired project name)
cd /var/www
sudo django-admin startproject myproject
cd myproject

# Adjust permissions to allow Apache to access the project files
sudo chown -R www-data:www-data /var/www/myproject

# Prepare Apache to serve the Django application
sudo tee /etc/apache2/sites-available/myproject.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/myproject
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    Alias /static /var/www/myproject/static
    <Directory /var/www/myproject/static>
        Require all granted
    </Directory>

    <Directory /var/www/myproject/myproject>
        <Files wsgi.py>
            Require all granted
        </Files>
    </Directory>

    WSGIDaemonProcess myproject python-path=/var/www/myproject python-home=/var/www/myproject
    WSGIProcessGroup myproject
    WSGIScriptAlias / /var/www/myproject/myproject/wsgi.py
</VirtualHost>
EOF

# Enable the new site and disable the default site
sudo a2ensite myproject
sudo a2dissite 000-default

# Reload Apache to apply changes
sudo systemctl reload apache2

