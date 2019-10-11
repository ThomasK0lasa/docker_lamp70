FROM ubuntu:16.04
MAINTAINER Thomas K <kolasa.at.work@gmail.com>
LABEL Description="Cutting-edge LAMP stack, based on Ubuntu 16.04 LTS. Includes .htaccess support and popular PHP7 features, including composer and mail() function." \
	License="Apache License 2.0" \
	Usage="docker run -d -p [HOST WWW PORT NUMBER]:80 -p [HOST DB PORT NUMBER]:3306 -v [HOST WWW DOCUMENT ROOT]:/var/www/html -v [HOST DB DOCUMENT ROOT]:/var/lib/mysql thk1/lamp" \
	Version="1.0"

RUN apt-get update
RUN apt-get upgrade -y

COPY debconf.selections /tmp/
RUN debconf-set-selections /tmp/debconf.selections

RUN apt-get install -y zip unzip wget
RUN apt-get install -y \
	php7.0 \
	php7.0-bz2 \
	php7.0-cgi \
	php7.0-cli \
	php7.0-common \
	php7.0-curl \
	php7.0-dev \
	php7.0-enchant \
	php7.0-fpm \
	php7.0-gd \
	php7.0-gmp \
	php7.0-imap \
	php7.0-interbase \
	php7.0-intl \
	php7.0-json \
	php7.0-ldap \
	php7.0-mbstring \
	php7.0-mcrypt \
	php7.0-mysql \
    php7.0-mysqli \
	php7.0-odbc \
	php7.0-opcache \
    php7.0-pdo \
	php7.0-pgsql \
	php7.0-phpdbg \
	php7.0-pspell \
	php7.0-readline \
	php7.0-recode \
	php7.0-snmp \
	php7.0-sqlite3 \
	php7.0-sybase \
	php7.0-tidy \
	php7.0-xmlrpc \
	php7.0-xsl \
	php7.0-zip
RUN apt-get install apache2 libapache2-mod-php7.0 -y
RUN apt-get install mariadb-common mariadb-server mariadb-client -y
RUN apt-get install git nodejs npm composer nano tree vim curl ftp -y
RUN npm install -g bower grunt-cli gulp
RUN apt-get install postfix -y

# needed for phpMyAdmin
RUN phpenmod mcrypt

# Add phpmyadmin
ENV PHPMYADMIN_VERSION=4.8.5
RUN wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz
RUN tar xfvz /tmp/phpmyadmin.tar.gz -C /var/www
RUN ln -s /var/www/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /var/www/phpmyadmin
RUN mv /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config.inc.php
RUN sed -i "17s/.*/\$cfg[\'blowfish_secret\'] = \'0KHv0V-uaNxlYQLrkt7uNWjyw,ejXRVX\';/" /var/www/phpmyadmin/config.inc.php
RUN mkdir /var/www/phpmyadmin/tmp
RUN chmod 777 /var/www/phpmyadmin/tmp

ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN cp -a /etc/apache2/. /tmp/apache2
RUN cp -a /etc/php/7.0/apache2/. /tmp/php

# colors for terminal
ENV TERM xterm-256color
ENV POSTFIX_START FALSE

# apache settings
ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**
ENV LOG_LEVEL warn
ENV WWW_INDEXING FALSE
ENV ALLOW_OVERRIDE All
# db settings
ENV ADD_USR TRUE
ENV DBLOGIN phpmyadmin
ENV DBPASS PassPlaceholder
ENV SET_ROOT_PASS TRUE
#php settings
ENV DATE_TIMEZONE UTC
ENV DEFAULT_PHPINI FALSE
ENV PHP_OPTIONS_OVERRIDE TRUE
ENV SHORT_TAGS FALSE
ENV UPLOAD_MAX_FILESIZE 34M
ENV POST_MAX_SIZE 48M
ENV MEMORY_LIMIT 128M
ENV MAX_EXECUTION_TIME 600
ENV MAX_INPUT_VARS 10000
ENV MAX_INPUT_TIME 400
ENV WWWDATA_USR_ID 33
ENV WWWDATA_GRP_ID 33

COPY run-lamp.sh /usr/sbin/

RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN chmod +x /usr/sbin/run-lamp.sh

VOLUME /var/www/html
VOLUME /var/log/apache2
VOLUME /var/lib/mysql
VOLUME /var/log/mysql
VOLUME /var/log/php_bkp
VOLUME /etc/apache2
VOLUME /etc/php/7.0/apache2/

EXPOSE 80
EXPOSE 3306

CMD ["/usr/sbin/run-lamp.sh"]