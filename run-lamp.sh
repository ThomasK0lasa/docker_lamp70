#!/bin/bash

function exportBoolean {
    if [ "${!1}" = "**Boolean**" ]; then
            export ${1}=''
    else 
            export ${1}='Yes.'
    fi
}

# setting server timezone
echo ${DATE_TIMEZONE} > /etc/timezone
ln -snf /usr/share/zoneinfo/${DATE_TIMEZONE} /etc/localtime

# db password managment
if [ $DBPASS == 'PassPlaceholder' ]; then
    PASS=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo ''`
else
    PASS=$DBPASS
fi

# Log settings
exportBoolean LOG_STDERR
if [ $LOG_STDERR ]; then
    /bin/ln -sf /dev/stderr /var/log/apache2/error.log
else
	LOG_STDERR='No.'
fi

exportBoolean LOG_STDOUT
# stdout server info:
if [ ! $LOG_STDOUT ]; then
cat << EOB
    
    APACHE SETTINGS
    ---------------
    · Redirect Apache access_log to STDOUT [LOG_STDOUT]: No.
    · Redirect Apache error_log to STDERR [LOG_STDERR]: $LOG_STDERR
    · Log Level [LOG_LEVEL]: $LOG_LEVEL
    · Allow override Apache settings (by htaccess) [ALLOW_OVERRIDE]: $ALLOW_OVERRIDE
    · Apache file indexing [WWW_INDEXING]: $WWW_INDEXING
    
EOB
else
    /bin/ln -sf /dev/stdout /var/log/apache2/access.log
fi

cat << EOC
    
    PHP SETTINGS
    ---------------
    · Override user with default php.ini [DEFAULT_PHPINI]: $DEFAULT_PHPINI
    · Override the php.ini with below options [PHP_OPTIONS_OVERRIDE]: $PHP_OPTIONS_OVERRIDE

    php.ini overrides:
    · PHP date timezone [DATE_TIMEZONE]: $DATE_TIMEZONE
    · Short tags [SHORT_TAGS]: $SHORT_TAGS
      Set 0 for options below to not override
    · UPLOAD_MAX_FILESIZE: $UPLOAD_MAX_FILESIZE
    · POST_MAX_SIZE: $POST_MAX_SIZE
    · MEMORY_LIMIT: $MEMORY_LIMIT
    · MAX_EXECUTION_TIME: $MAX_EXECUTION_TIME
    · MAX_INPUT_VARS: $MAX_INPUT_VARS
    · MAX_INPUT_TIME: $MAX_INPUT_TIME
    
EOC

# Check if Postfix should be started
if [ $POSTFIX_START == 'TRUE' ]; then
    /usr/sbin/postfix start
fi

# Check if Volume is empty - install DB in case if it is missing any data
if [ ! -f /var/lib/mysql/ibdata1 ]; then
    mysql_install_db
fi

# Run MariaDB
mysqld_safe --timezone=${DATE_TIMEZONE} &
sleep 20

# Set root user password
if [ $SET_ROOT_PASS == 'TRUE' ]; then
    mysqladmin -u root password $PASS
fi

# Add phpmyadmin user
if [ $ADD_USR == 'TRUE' ]; then
    mysql -e "use mysql;
    GRANT ALL ON *.* TO '$DBLOGIN'@'%' IDENTIFIED BY '$PASS';
    GRANT ALL PRIVILEGES ON *.* TO '$DBLOGIN'@'%' WITH GRANT OPTION;
    FLUSH PRIVILEGES;"
fi

# Print log for DB access

cat << EOD

    DB ACCESS
    ---------------
    · Add DB root user for PhpMyAdmin [ADD_USR]: $ADD_USR
    · Set DB root user password [SET_ROOT_PASS]: $SET_ROOT_PASS
EOD
if [ $ADD_USR == 'TRUE' ]; then
cat << EOD
    · DB login (this is a root user): $DBLOGIN
    · DB password for '$DBLOGIN': $PASS
EOD
fi
if [ $SET_ROOT_PASS == 'TRUE' ]; then
    echo "    · DB password for 'root': $PASS"
else
    echo "    · DB 'root' has no password"
fi
echo "";

# Copy default Apache data
if [ ! -f /etc/apache2/apache2.conf ]; then
    cp -a /tmp/apache2/. /etc/apache2
fi
if [ $WWW_INDEXING == 'TRUE' ]; then
    sed -i '13s/Options FollowSymLinks MultiViews/Options Indexes FollowSymLinks MultiViews/' /etc/apache2/sites-available/000-default.conf
fi
# Allows override of apache settings with htaccess file
if [ $ALLOW_OVERRIDE == 'All' ]; then
    /bin/sed -i 's/AllowOverride\ None/AllowOverride\ All/g' /etc/apache2/apache2.conf
fi
if [ $LOG_LEVEL != 'warn' ]; then
    /bin/sed -i "s/LogLevel\ warn/LogLevel\ ${LOG_LEVEL}/g" /etc/apache2/apache2.conf
fi

# If there's no php.ini then copy default ini file
if [ ! -f /etc/php/7.0/apache2/php.ini ]; then
    cp -a /tmp/php/. /etc/php/7.0/apache2
else
    if [ $DEFAULT_PHPINI == 'TRUE' ] || [ $PHP_OPTIONS_OVERRIDE == 'TRUE' ]; then
        #backuping old ini settings before override
        CURR_DATE=$(date "+%y-%m-%d_%H%M%S")
        mkdir -p /var/log/php_bkp/$CURR_DATE
        cp -a /etc/php/7.0/apache2/. /var/log/php_bkp/$CURR_DATE
    fi
    if [ $DEFAULT_PHPINI == 'TRUE' ]; then
        cp -rfa /tmp/php/. /etc/php/7.0/apache2
    fi
fi
if [ $PHP_OPTIONS_OVERRIDE == 'TRUE' ]; then
    if [ $UPLOAD_MAX_FILESIZE != 'IGNORE' ]; then
        /bin/sed -i "s/.*upload_max_filesize\ \=.*/upload_max_filesize = $UPLOAD_MAX_FILESIZE/g" /etc/php/7.0/apache2/php.ini
    fi
    if [ $POST_MAX_SIZE != 'IGNORE' ]; then
        /bin/sed -i "s/.*post_max_size\ \=.*/post_max_size = $POST_MAX_SIZE/g" /etc/php/7.0/apache2/php.ini
    fi
    if [ $MEMORY_LIMIT != 'IGNORE' ]; then
        /bin/sed -i "s/.*memory_limit\ \=.*/memory_limit = $MEMORY_LIMIT/g" /etc/php/7.0/apache2/php.ini
    fi
    if [ $MAX_EXECUTION_TIME != 'IGNORE' ]; then
        /bin/sed -i "s/.*max_execution_time\ \=.*/max_execution_time = $MAX_EXECUTION_TIME/g" /etc/php/7.0/apache2/php.ini
    fi
    if [ $MAX_INPUT_VARS != 'IGNORE' ]; then
        /bin/sed -i "s/.*max_input_vars\ \=.*/max_input_vars = $MAX_INPUT_VARS/g" /etc/php/7.0/apache2/php.ini
    fi
    if [ $MAX_INPUT_TIME != 'IGNORE' ]; then
        /bin/sed -i "s/.*max_input_time\ \=.*/max_input_time = $MAX_INPUT_TIME/g" /etc/php/7.0/apache2/php.ini
    fi
    if [ $SHORT_TAGS == 'TRUE' ]; then
        /bin/sed -i "s/.*short_open_tag\ \=\ Off/short_open_tag\ \=\ On/g" /etc/php/7.0/apache2/php.ini
    fi
    if [ $DATE_TIMEZONE != '' ]; then 
        /bin/sed -i "s~\;date\.timezone\ \=~date\.timezone\ \=\ ${DATE_TIMEZONE}~" /etc/php/7.0/apache2/php.ini
    fi
fi

# Run Apache:
a2enmod rewrite headers
usermod --non-unique --uid $WWWDATA_USR_ID www-data \
  && groupmod --non-unique --gid $WWWDATA_GRP_ID www-data
chown -R www-data:www-data /var/www/html
if [ $LOG_LEVEL == 'debug' ] && [ $APACHE == 'FALSE' ]; then
    /usr/sbin/apachectl -DFOREGROUND -k start -e debug
else
    &>/dev/null /usr/sbin/apachectl -DFOREGROUND -k start
fi