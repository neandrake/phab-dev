FROM ubuntu:22.04

RUN apt-get update && \
    apt-get upgrade -y

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y sudo netcat-traditional iputils-ping git nginx mariadb-client ca-certificates software-properties-common apt-transport-https && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y php7.4 php7.4-fpm php7.4-mysql php7.4-gd php7.4-curl php7.4-apcu php7.4-cli php7.4-mbstring php7.4-zip php7.4-xdebug php7.4-iconv

ADD ./docker-context/nginx.conf /etc/nginx/
ADD ./docker-context/phab.conf /etc/nginx/conf.d/
ADD ./docker-context/www.conf /etc/php/7.4/fpm/pool.d/

# Allow www-data (entrypoint) to sudo as root to run nginx
RUN echo "www-data  ALL=(root)  NOPASSWD: /usr/sbin/nginx" >> /etc/sudoers && \
    echo "www-data  ALL=(root)  NOPASSWD: /usr/sbin/php-fpm7.4" >> /etc/sudoers && \
    echo "www-data  ALL=(phab-phd)  NOPASSWD: ALL" >> /etc/sudoers && \
    echo "phab-phd  ALL=(root)  NOPASSWD: ALL" >> /etc/sudoers

RUN useradd --system phab-phd && \
    groupadd phab && \
    usermod -a -G phab phab-phd && \
    usermod -a -G phab www-data

RUN mkdir -p /opt/phabdev/ && \
    mkdir -p /opt/filestore && \
    mkdir -p /opt/repos && \
    mkdir -p /var/log/phabricator && \
    mkdir -p /run/php/

RUN chown -R phab-phd:phab /opt/ && \
    chown -R www-data:phab /var/log/phabricator/ && \
    chmod -R g+rw /opt/ && \
    chmod -R g+rw /var/log/phabricator/

# Run entrypoint as the web service account
USER www-data

ADD ./docker-context/local.json /opt/phabdev
ADD ./docker-context/entrypoint.sh /opt/phabdev

ENTRYPOINT ["/opt/phabdev/entrypoint.sh"]
