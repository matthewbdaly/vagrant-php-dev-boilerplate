#!/usr/bin/env bash

# Update apt
apt-get update

# Install requirements
apt-get install -y apache2
apt-get install -y php5
apt-get install -y php5-cli
apt-get install -y php5-mcrypt
apt-get install -y php5-gd
apt-get install -y php-apc
apt-get install -y git
apt-get install -y sqlite
apt-get install -y php5-sqlite
apt-get install -y curl
apt-get install -y php5-curl
apt-get install -y msmtp ca-certificates vim-nox

# Install MySQL
sudo debconf-set-selections <<< 'mysql-server-<version> mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server-<version> mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server

# If phpmyadmin does not exist, install it
if [ ! -f /etc/phpmyadmin/config.inc.php ];
then

    # Used debconf-get-selections to find out what questions will be asked
    # This command needs debconf-utils

    # Handy for debugging. clear answers phpmyadmin: echo PURGE | debconf-communicate phpmyadmin

    echo 'phpmyadmin phpmyadmin/dbconfig-install boolean false' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections

    echo 'phpmyadmin phpmyadmin/app-password-confirm password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/mysql/admin-pass password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/password-confirm password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/setup-password password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/database-type select mysql' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/mysql/app-pass password root' | debconf-set-selections
    
    echo 'dbconfig-common dbconfig-common/mysql/app-pass password root' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/mysql/app-pass password' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/password-confirm password root' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/app-password-confirm password root' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/app-password-confirm password root' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/password-confirm password root' | debconf-set-selections
    
    apt-get -y install phpmyadmin
fi


# Setup hosts file
VHOST=$(cat <<EOF
    <VirtualHost *:80>
            ServerAdmin webmaster@localhost

            DocumentRoot /var/www/
            <Directory />
                    Options FollowSymLinks
                    AllowOverride All
            </Directory>
            <Directory /var/www/>
                    Options Indexes FollowSymLinks MultiViews
                    AllowOverride All
                    Order allow,deny
                    allow from all
            </Directory>
            DirectoryIndex index.php
            ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
            <Directory "/usr/lib/cgi-bin">
                    AllowOverride None
                    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                    Order allow,deny
                    Allow from all
            </Directory>
    </VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/default

# Configure MSMTP
MSMTP=$(cat <<EOF
# ------------------------------------------------------------------------------
# msmtp System Wide Configuration file
# ------------------------------------------------------------------------------

# A system wide configuration is optional.
# If it exists, it usually defines a default account.
# This allows msmtp to be used like /usr/sbin/sendmail.

# ------------------------------------------------------------------------------
# Accounts
# ------------------------------------------------------------------------------

# Main Account
defaults
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account default
host smtp.gmail.com
port 587
auth on
from user@gmail.com
user user@gmail.com
password password
logfile /var/log/msmtp.log

# ------------------------------------------------------------------------------
# Configurations
# ------------------------------------------------------------------------------

# Construct envelope-from addresses of the form "user@oursite.example".
#auto_from on
#maildomain fermmy.server

# Use TLS.
#tls on
#tls_trust_file /etc/ssl/certs/ca-certificates.crt

# Syslog logging with facility LOG_MAIL instead of the default LOG_USER.
# Must be done within "account" sub-section above
#syslog LOG_MAIL

# Set a default account

# ------------------------------------------------------------------------------
EOF
)
echo "${MSMTP}" > /etc/msmtprc

# Configure PHP to use MSMTP
sudo sed -i "s[^;sendmail_path =.*[sendmail_path = '/usr/bin/msmtp -t'[g" /etc/php5/apache2/php.ini

# Enable mod_rewrite
sudo a2enmod rewrite

# Restart Apache
sudo service apache2 restart

# Create the BVL database
mysql -uroot -proot < /var/www/sql/setup
