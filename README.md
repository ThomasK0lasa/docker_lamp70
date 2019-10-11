![docker_logo](https://github.com/ThomasK0lasa/docker_lamp70/blob/02c8702488c5a280804d6347c5731efdc91adddc/img/docker_139x115.png) ![thk_logo](https://github.com/ThomasK0lasa/docker_lamp70/blob/02c8702488c5a280804d6347c5731efdc91adddc/img/thk-logo-white_100x100.png) ![lamp_logo](https://github.com/ThomasK0lasa/docker_lamp70/blob/02c8702488c5a280804d6347c5731efdc91adddc/img/lamp-stack_400x100.png)

This Docker container implements LAMP stack with a set of popular PHP modules and PhpMyAdmin. The docker image was designed with persistent data volume in mind and if You don't have any data the default data will be copied to Your volumes (such as DB, Apache settings, php settings).

If You would like image with newer (or older) version of PHP (5.6, 7.0, 7.2, 7.3) check out my second docker image here: [lamp_extended](http://hub.docker.com/r/thk1/lamp_extended). This image was tested and used sucesfully on Synology DMS6.2 for hosting purposes (without mail part). All sugestions and comments are welcomed.

Includes the following components:

 * Ubuntu 16.04 LTS Xenial Xerus base image.
 * Apache HTTP Server 2.4.18
 * MariaDB 10.0
 * Postfix 3.1
 * PHP 7.0.13
 * PHP modules:
 	bz2, calendar, Core, ctype, curl, date, dom, enchant, exif, fileinfo, filter, ftp, gd, gettext, gmp, hash, iconv, imap, interbase, intl, json, ldap, libxml, mbstring, mcrypt, mysqli, mysqlnd, odbc, openssl, pcntl, pcre, PDO, pdo_dblib, PDO_Firebird, pdo_mysql, PDO_ODBC, pdo_pgsql, pdo_sqlite, pgsql, Phar, posix, pspell, readline, recode, Reflection, session, shmop, SimpleXML, snmp, sockets, SPL, sqlite3, standard, sysvmsg, sysvsem, sysvshm, tidy, tokenizer, wddx, xml, xmlreader, xmlrpc, xmlwriter, xsl, Zend OPcache, zip, zlib
 * Development tools:
	* git
	* composer
	* npm / nodejs
	* bower
	* vim
	* tree
	* nano
	* ftp
	* curl
* phpmyadmin 4.8.5

Installation from [Docker registry hub](https://hub.docker.com/r/thk1/lamp70).
----

You can download the image using the following command:

```bash
docker pull thk1/lamp70
```

Environment variables
----

This image uses environment variables to allow the configuration of some parameteres at run time:

* Variable name: LOG_STDOUT
* Default value: Empty string.
* Accepted values: Any string to enable, empty string or not defined to disable.
* Description: Output Apache access log through STDOUT, so that it can be accessed through the [container logs](https://docs.docker.com/reference/commandline/logs/).
* Concerns: Docker \ Ubuntu \ Apache

----

* Variable name: LOG_STDERR
* Default value: Empty string.
* Accepted values: Any string to enable, empty string or not defined to disable.
* Description: Output Apache error log through STDERR, so that it can be accessed through the [container logs](https://docs.docker.com/reference/commandline/logs/).
* Concerns: Docker \ Ubuntu \ Apache

----

* Variable name: LOG_LEVEL
* Default value: warn
* Accepted values: debug, info, notice, warn, error, crit, alert, emerg
* Description: Value for Apache's [LogLevel directive](http://httpd.apache.org/docs/2.4/en/mod/core.html#loglevel).
* Concerns: Apache

----

* Variable name: WWW_INDEXING
* Default value: FALSE
* Accepted values: TRUE, FALSE
* Description: Used to enable (`TRUE`) or disable (`FALSE`) the Apache indexing of files.
* Concerns: Apache

----

* Variable name: ALLOW_OVERRIDE
* Default value: All
* Accepted values: All, None - value for Apache's [AllowOverride directive](http://httpd.apache.org/docs/2.4/en/mod/core.html#allowoverride).
* Description: Used to enable (`All`) or disable (`None`) the usage of an `.htaccess` file.
* Concerns: Apache

----

* Variable name: ADD_USR
* Default value: TRUE
* Accepted values: TRUE, FALSE
* Description: User with root rights of selected name and password will be added to MariaDB.
* Concerns: MariaDB

----

* Variable name: DBLOGIN
* Default value: phpmyadmin
* Accepted values: Any (not recommended to use special characters, prohibited to use spaces)
* Description: The name of new user in DB.
* Concerns: MariaDB

----

* Variable name: DBPASS
* Default value: PassPlaceholder
* Accepted values: Any (not recommended to use special characters, prohibited to use spaces) or leave PassPlaceholder to get new automatically generated password.
* Description: Password for new user in DB.
* Concerns: MariaDB

----

* Variable name: SET_ROOT_PASS
* Default value: TRUE
* Accepted values: TRUE, FALSE
* Description: Sets same password (as in DBPASS) for 'root' user in DB
* Concerns: MariaDB

----

* Variable name: DATE_TIMEZONE
* Default value: UTC
* Accepted values: Any of PHP's [supported timezones](http://php.net/manual/en/timezones.php)
* Description: Set php.ini default date.timezone directive and sets MariaDB as well.
* Concerns: PHP

----

* Variable name: DEFAULT_PHPINI
* Default value: FALSE
* Accepted values: TRUE, FALSE
* Description: Will override (`TRUE`) any existing php.ini with default one
* Concerns: PHP

----

* Variable name: PHP_OPTIONS_OVERRIDE
* Default value: TRUE
* Accepted values: TRUE, FALSE
* Description: Will override (`TRUE`) specific php.ini settings depending on variables - SHORT_TAGS, UPLOAD_MAX_FILESIZE, POST_MAX_SIZE, MEMORY_LIMIT, MAX_EXECUTION_TIME, MAX_INPUT_VARS and MAX_INPUT_TIME
* Concerns: PHP

----

* Variable name: SHORT_TAGS
* Default value: FALSE
* Accepted values: TRUE, FALSE
* Description: Turn on or off php short tags handling. This option will be overrided in php.ini
* Concerns: PHP
* Condition: If PHP_OPTIONS_OVERRIDE won't be set to TRUE this variable will be ignored

----

* Variable name: UPLOAD_MAX_FILESIZE
* Default value: 34M
* Accepted values: Shorthand byte value or IGNORE
* Description: [Shorthand byte value](https://www.php.net/manual/en/faq.using.php#faq.using.shorthandbytes). This option will be overrided in php.ini or won't (if set to `IGNORE`)
* Concerns: PHP
* Condition: If PHP_OPTIONS_OVERRIDE won't be set to TRUE this variable will be ignored

----

* Variable name: POST_MAX_SIZE
* Default value: 48M
* Accepted values: Shorthand byte value or IGNORE
* Description: [Shorthand byte value](https://www.php.net/manual/en/faq.using.php#faq.using.shorthandbytes). This option will be overrided in php.ini or won't (if set to `IGNORE`)
* Concerns: PHP
* Condition: If PHP_OPTIONS_OVERRIDE won't be set to TRUE this variable will be ignored

----

* Variable name: MEMORY_LIMIT
* Default value: 128M
* Accepted values: Shorthand byte value or IGNORE
* Description: [Shorthand byte value](https://www.php.net/manual/en/faq.using.php#faq.using.shorthandbytes). This option will be overrided in php.ini or won't (if set to `IGNORE`)
* Concerns: PHP
* Condition: If PHP_OPTIONS_OVERRIDE won't be set to TRUE this variable will be ignored

----

* Variable name: MAX_EXECUTION_TIME
* Default value: 600
* Accepted values: Integer or IGNORE
* Description: Time in seconds. This option will be overrided in php.ini or won't (if set to `IGNORE`)
* Concerns: PHP
* Condition: If PHP_OPTIONS_OVERRIDE won't be set to TRUE this variable will be ignored

----

* Variable name: MAX_INPUT_VARS
* Default value: 10000
* Accepted values: Integer or IGNORE
* Description: This option will be overrided in php.ini or won't (if set to `IGNORE`)
* Concerns: PHP
* Condition: If PHP_OPTIONS_OVERRIDE won't be set to TRUE this variable will be ignored

----

* Variable name: MAX_INPUT_TIME
* Default value: 400
* Accepted values: Integer or IGNORE
* Description: This option will be overrided in php.ini or won't (if set to `IGNORE`)
* Concerns: PHP
* Condition: If PHP_OPTIONS_OVERRIDE won't be set to TRUE this variable will be ignored

----

* Variable name: WWWDATA_USR_ID
* Default value: 33
* Concerns: Apache \ Ubuntu
* Accepted values: Integer
* Description: Sets id for Apache user in docker container

----

* Variable name: WWWDATA_GRP_ID
* Default value: 33
* Concerns: Apache \ Ubuntu
* Accepted values: Integer
* Description: Sets id for Apache group in docker container

----

* Variable name: TERM
* Default value: xterm-256color
* Concerns: Docker \ Ubuntu
* Accepted values:
* Description: TERM variable stores the name of an entry in the terminfo database that helps the OS determine how to display information to your terminal

----

* Variable name: POSTFIX_START
* Default value: FALSE
* Concerns: Postfix
* Accepted values: TRUE, FALSE
* Description: Starts postfix service


Exposed port and volumes
----

The image exposes ports `80` and `3306`, and exports such volumes:

* `/var/log/apache2`, containing Apache log files.
* `/var/log/mysql` containing MariaDB log files.
* `/var/log/php_bkp` php settings are copied here (ICE) before being overrided.
* `/var/www/html`, used as Apache's [DocumentRoot directory](http://httpd.apache.org/docs/2.4/en/mod/core.html#documentroot).
* `/var/lib/mysql`, where MariaDB data files are stored.
* `/etc/apache2`, where Apache configuration files are stored.
* `/etc/php/7.0/apache2`, where PHP initialization files are stored.

Please, refer to https://docs.docker.com/storage/volumes for more information on using host volumes.

The user and group owner id for the DocumentRoot directory `/var/www/html` are both 33 (`uid=33(www-data) gid=33(www-data) groups=33(www-data)`).

The user and group owner id for the MariaDB directory `/var/log/mysql` are 105 and 108 repectively (`uid=105(mysql) gid=108(mysql) groups=108(mysql)`).

Use cases
----

#### Create a temporary container for testing purposes:

```
	docker run -i -t --rm thk1/lamp70 /usr/sbin/run-lamp.sh &
```

#### Create a temporary container to debug a web app:

```
	docker run --rm -p 8080:80 -e LOG_STDOUT=true -e LOG_STDERR=true -e LOG_LEVEL=debug -v /my/data/directory:/var/www/html thk1/lamp70
```

#### Create a container linking to another [MySQL container](https://registry.hub.docker.com/_/mysql/):

```
	docker run -d --link my-mysql-container:mysql -p 8080:80 -v /my/data/directory:/var/www/html -v /my/logs/directory:/var/log/apache2 --name my-lamp-container thk1/lamp70
```

#### Get inside a running container and open a MariaDB console:

```
	docker exec -i -t my-lamp-container bash
	mysql -u root
```

Credits
----
This image was originally branched from:
* Fer Uría LAMP container: https://hub.docker.com/r/fauria/lamp
* Matt Rayner LAMP container: https://github.com/mattrayner/docker-lamp
