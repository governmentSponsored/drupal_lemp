FROM ubuntu:16.04
RUN apt-get update && apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository ppa:nginx/stable -y
RUN apt-get update && apt-get install nginx-full -y
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y
RUN apt-get update &&  apt-get install curl php7.1-mysql php7.1-xml php7.1-gd php7.1-fpm php-cli php-mbstring git unzip vim -y
RUN cd /root && curl -sS https://getcomposer.org/installer -o /root/composer-setup.php
RUN php /root/composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN mkdir /var/www/docker_platform
RUN >/etc/nginx/sites-available/default
COPY ./run.sh /root/set-nginx-conf.sh
RUN chmod +x /root/set-nginx-conf.sh &&  sleep 2 && /root/set-nginx-conf.sh > /etc/nginx/sites-available/default
RUN groupadd -r mysql && useradd -r -g mysql mysql
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
RUN add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirrors.accretive-networks.net/mariadb/repo/10.2/ubuntu xenial main'
RUN { \
                echo mariadb-server mysql-server/root_password password 'admin'; \
                echo mariadb-server mysql-server/root_password_again password 'admin'; \
        } | debconf-set-selections \
        && apt-get update \
        && apt-get install -y \
                mariadb-server \
         && rm -rf /var/lib/apt/lists/*
VOLUME /var/lib/mysql
COPY ./start.sh /root/start.sh
RUN chmod +x /root/start.sh &&  sleep 2
RUN chown -R www-data:www-data /var/www/docker_platform
EXPOSE 80 443 3306 9000 22 25
COPY ./set-mysql-conf.sh /root/set-mysql-conf.sh
RUN chmod +x /root/set-mysql-conf.sh &&  sleep 2 && /root/set-mysql-conf.sh
VOLUME ["/var/lib/mysql", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/docker_platform"]
