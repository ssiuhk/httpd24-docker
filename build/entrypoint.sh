#!/bin/sh
set -ex

# Start forego or execute a command in the virtualenv
if [ "$#" -eq 0 ]; then

    if [ ! -e /export/wwwroot/localhost/ssl/localhost.crt ] || [ ! -e /export/wwwroot/localhost/ssl/private/localhost.key ]; then
        mkdir -p /export/wwwroot/localhost/ssl/private && \
        chmod 700 /export/wwwroot/localhost/ssl/private
        openssl req -new -newkey rsa:4096 -x509 -days 1096 -nodes \
            -keyout /export/wwwroot/localhost/ssl/private/localhost.key \
            -out /export/wwwroot/localhost/ssl/localhost.crt \
            -subj "/C=US/O=localhost/OU=localhost/CN=localhost"
    fi

    sed -i "s/^#ServerName.*/ServerName ${SERVER_NAME}:80/g" /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf && \
    sed -i "s/^#ServerName.*/ServerName ${SERVER_NAME}:443/g" /opt/rh/httpd24/root/etc/httpd/conf.d/ssl.conf && \
    sed -i "s/^ServerAdmin.*/ServerAdmin ${SERVER_ADMIN}/g" /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf && \
    sed -i "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/g " /etc/opt/rh/rh-php72/php.ini && \
    sed -i "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/g " /etc/opt/rh/rh-php72/php.ini && \
    sed -i "s/\#relayhost = \[an.ip.add.ress\]/relayhost = ${MAIL_RELAY_HOST}/g" /etc/postfix/main.cf && \
    sed -i "s/\#mydomain = domain.tld/mydomain = ${MY_DOMAIN}/g"  /etc/postfix/main.cf && \
    sed -i 's/\#myorigin = $mydomain/myorigin = $mydomain/g' /etc/postfix/main.cf && \
    echo "date.timezone = \"${TIME_ZONE}\"" >> /etc/opt/rh/rh-php72/php.ini


    export | grep GROUP | cut -f2 -d'=' | while read LINE
    do
	LINE=$(echo ${LINE} | sed 's/"//g')
        [ $(grep -oc ${LINE} /etc/group) -lt 1 ] && echo ${LINE} >> /etc/group
    done

    export | grep USER | cut -f2 -d'=' | while read LINE
    do
	LINE=$(echo ${LINE} | sed 's/"//g')
	if [ $(grep -oc ${LINE} /etc/passwd) -lt 1 ]; then
	    echo ${LINE} >> /etc/passwd
            USERNAME=$(echo ${LINE} | cut -f1 -d ':')
            mkhomedir_helper ${USERNAME}
            su -l ${USERNAME} -c 'mkdir -p ${HOME}/{public_html,logs}'
	fi
    done

    /usr/sbin/postfix start
    /opt/rh/httpd24/root/usr/sbin/httpd-scl-wrapper $OPTIONS -DFOREGROUND

else
        "$@"
fi

