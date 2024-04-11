#!/bin/bash

# Update and install necessary packages
apt-get update
apt-get install -y python3-pip python3-dev libpq-dev
apt-get install -y samba krb5-user sssd sssd-tools libnss-sss libpam-sss ntp ntpdate realmd adcli

# Install Django
pip3 install django

# (Optional) Create a new Django project if needed
# django-admin startproject myproject

# Install necessary packages for AD integration
DEBIAN_FRONTEND=noninteractive apt-get install -y krb5-user libpam-krb5 libpam-ccreds auth-client-config

# Configure Kerberos
echo "[libdefaults]
 default_realm = YOUR_DOMAIN.COM
 dns_lookup_realm = false
 dns_lookup_kdc = true
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 rdns = false" > /etc/krb5.conf

# Replace YOUR_DOMAIN.COM with your actual domain

# Join the VM to the Domain
echo "your_domain_admin_password" | kinit your_domain_admin
net ads join -U your_domain_admin

# Configure SSSD for AD integration
echo "[sssd]
domains = YOUR_DOMAIN.COM
config_file_version = 2
services = nss, pam

[domain/YOUR_DOMAIN.COM]
ad_domain = YOUR_DOMAIN.COM
krb5_realm = YOUR_DOMAIN.COM
realmd_tags = manages-system joined-with-samba
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True
use_fully_qualified_names = False
fallback_homedir = /home/%u" > /etc/sssd/sssd.conf

# Replace YOUR_DOMAIN.COM with your actual domain

# Restart SSSD and necessary services to apply changes
systemctl restart sssd
systemctl enable sssd

# Additional configuration might be needed here depending on the environment and specific requirements

