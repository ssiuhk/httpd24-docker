FROM centos:latest

ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

VOLUME [ "/sys/fs/cgroup" ]

RUN yum install -y centos-release-scl-rh epel-release && \
                yum clean all && \
                yum makecache && \
                yum install -y \
                rsyslog \
                crontabs \
                logrotate \
                postfix \
                ca-certificates \
                curl \
                xz \
                openssh-clients \
                httpd24-httpd-tools \
                httpd24-httpd \
                httpd24-httpd-devel \
                httpd24-httpd-manual \
                httpd24-mod_ssl \
                git \
                mariadb \
                vim \
                libcap \
                libcap-devel \
                gcc \
		curl \
		wget \
                rh-php72 \
                rh-php72-php \
                rh-php72-php-mbstring \
                rh-php72-php-fpm \
                rh-php72-php-zip \
                rh-php72-php-opcache \
                rh-php72-php-process \
                rh-php72-php-common \
                rh-php72-php-mysqlnd \
                rh-php72-php-pdo \
                rh-php72-php-pear \
                rh-php72-php-cli \
                rh-php72-php-xml \
                rh-php72-php-json \
                rh-php72-php-ldap \
                && yum clean all && \
                rm -rf /var/cache/yum/*

RUN             cd /tmp && \
                git clone https://github.com/mind04/mod-ruid2.git && \
                cd mod-ruid2 && \
                /opt/rh/httpd24/root/usr/bin/apxs -a -i -l cap -c mod_ruid2.c && \
                sed -i 's/inet_interfaces = localhost/inet_interfaces = all/g' /etc/postfix/main.cf && \
                echo "ServerTokens Prod" >> /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf && \
                echo "ServerSignature Email" >> /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf && \
                mkdir -p /home/wwwroot && \
                echo "Running ..." > /opt/rh/httpd24/root/var/www/html/index.html && \
		wget -O /tmp/tini.rpm https://github.com/krallin/tini/releases/download/v0.18.0/tini_0.18.0-amd64.rpm && \
		rpm -ivh /tmp/tini.rpm

COPY entrypoint.sh /entrypoint.sh
# Catch all if vhost not matched
COPY 0Default.conf /opt/rh/httpd24/root/etc/httpd/conf.d/0Default.conf
COPY zDefault.conf /opt/rh/httpd24/root/etc/httpd/conf.d/zDefault.conf

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
WORKDIR /home/wwwroot/

EXPOSE 80
EXPOSE 443


HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1

LABEL maintainer="Sam SIU <23556929+ssiuhk@users.noreply.github.com>" 

