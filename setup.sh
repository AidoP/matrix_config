#!/bin/sh
set -e

echo 'This script is a rough guide only. Please check over it before running. Ctrl-C to exit and read first.'
read -p 'Press enter to continue...' a

# Update System
apt update
apt upgrade

# Add Synapse Repo
# https://github.com/matrix-org/synapse/blob/develop/INSTALL.md#debianubuntu
apt install -y lsb-release wget apt-transport-https
wget -O /usr/share/keyrings/matrix-org-archive-keyring.gpg https://packages.matrix.org/debian/matrix-org-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/matrix-org-archive-keyring.gpg] https://packages.matrix.org/debian/ $(lsb_release -cs) main" |
    tee /etc/apt/sources.list.d/matrix-org.list
apt update
apt install matrix-synapse-py3

# Will have TUI setup. If there is an error ensure you set your TERM env var
export TERM=xterm-color
    # Try again

# Ensure that the matrix server name is a valid domain or subdomain

# Install Packages
apt install postgresql certbot lighttpd

# Disable service while configuring, except postgres as we connect to it for configuration
systemctl stop lighttpd
systemctl stop matrix-synapse
systemctl start postgresql

# Collect your TLS certificates using certbot
certbot certonly --standalone
# Ensure the domain is pointing at this server and port 80 is open
# Close port 80 after as it is a security hole

# Modify the lighttpd config for the reverse proxy
echo 'Starting vim to modify the lighttpd config. Replace <domain> with the path created by certbot. Should be the domain name, but check it in case.'
read -p 'Press enter to continue...' a

vim lighttpd.conf
echo "Copying config to /etc/lighttpd/lighttpd.conf"
cp lighttpd.conf /etc/lighttpd/lighttpd.conf
chown root:root /etc/lighttpd/lighttpd.conf
chmod 644 /etc/lighttpd/lighttpd.conf

# Setup the Postgres database
# Please check the script
# https://github.com/matrix-org/synapse/blob/develop/docs/postgres.md
chmod -R a+r postgres.sh
sudo -u postgres sh postgres.sh

# Configure synapse
# Please check through the config rather than blindly using it. It is merely a starting point
echo "Starting vim to modify the matrix homeserver.yaml configuration. Replace <password> with the Postgres databse password you chose. Check over the whole configuration thoroughly."
read -p 'Press enter to continue...' a

vim homeserver.yaml
cp homeserver.yaml /etc/matrix-synapse/homeserver.yaml
chown matrix-synapse:matrix:synapse /etc/matrix-synapse/homeserver.yaml
chmod 770 /etc/matrix-synapse/homeserver.yaml

# Enable and start the systemd services
systemctl enable matrix-synapse
systemctl enable lighttpd
systemctl enable postgresql

systemctl start matrix-synapse
systemctl start lighttpd
systemctl start postgresql
