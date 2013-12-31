#!/usr/bin/env bash

# Update apt
apt-get update

# Install requirements
apt-get install -y apache2 build-essential checkinstall php5 php5-cli php5-mcrypt php5-gd php-apc git sqlite php5-sqlite curl php5-curl php5-dev php-pear php5-xdebug vim-nox mongodb ruby rubygems sqlite3 libsqlite3-dev
sudo pecl install mongo

# Install Mailcatcher
sudo gem install mailcatcher

# Setup hosts file
VHOST=$(cat <<EOF
    <VirtualHost *:80>
            ServerAdmin webmaster@localhost

            DocumentRoot /var/www/webapp/
            Alias /webgrind /var/www/webgrind
            <Directory />
                    Options FollowSymLinks
                    AllowOverride All
            </Directory>
            <Directory /var/www/webapp/>
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
            Alias /xhprof "/usr/share/php/xhprof_html"
            <Directory "/usr/share/php/xhprof_html">
                Options FollowSymLinks
                AllowOverride All
                Order allow,deny
                allow from all
            </Directory>
    </VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/default

# Configure PHP to use Mailcatcher and MongoDB
sudo sed -i "s[^;sendmail_path =.*[sendmail_path = '/usr/bin/env catchmail'[g" /etc/php5/apache2/php.ini
if grep -Fxqv "extension=mongo.so" /etc/php5/apache2/php.ini
then
    echo "extension=mongo.so" >> /etc/php5/apache2/php.ini
fi

# Configure XDebug
XDEBUG=$(cat <<EOF
zend_extension=/usr/lib/php5/20100525/xdebug.so
xdebug.profiler_enable=1
xdebug.profiler_output_dir="/tmp"
xdebug.profiler_append=0
xdebug.profiler_output_name = "cachegrind.out.%t.%p"
EOF
)
echo "${XDEBUG}" > /etc/php5/conf.d/xdebug.ini

# Install webgrind if not already present
if [ ! -d /var/www/webgrind ];
then
    git clone https://github.com/jokkedk/webgrind.git /var/www/webgrind
fi

# Install XHProf
CONFIG=$(cat <<EOF
extension=xhprof.so
xhprof.output_dir="/var/tmp/xhprof"
EOF
)
echo "${CONFIG}" > /etc/php5/conf.d/xhprof.ini
if [ ! -d /usr/share/php/xhprof_html ];
then
    sudo pecl install xhprof-beta
fi

if [ ! -d /var/tmp/xhprof ];
then
    sudo mkdir /var/tmp/xhprof
    sudo chmod 777 /var/tmp/xhprof
fi

# Install Composer globally
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Enable mod_rewrite
sudo a2enmod rewrite

# Restart Apache
sudo service apache2 restart

# Start Mailcatcher
mailcatcher --ip=0.0.0.0
