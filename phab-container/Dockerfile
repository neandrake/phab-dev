FROM ubuntu:22.04 as phabdev_base

RUN apt-get update && \
    apt-get upgrade -y

ENV DEBIAN_FRONTEND noninteractive

ENV PHPVER 8.2

RUN apt-get install -y sudo netcat-traditional iputils-ping ca-certificates software-properties-common apt-transport-https && \
    apt-get install -y mariadb-client nginx && \
    apt-get install -y git mercurial && \
    apt-get install -y vim less ripgrep fd-find && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y php${PHPVER} php${PHPVER}-fpm php${PHPVER}-mysql php${PHPVER}-gd php${PHPVER}-curl php${PHPVER}-apcu php${PHPVER}-cli php${PHPVER}-mbstring php${PHPVER}-zip php${PHPVER}-xdebug php${PHPVER}-iconv && \
    apt-get install -y python3 python3-pip && \
    pip install Pygments

FROM phabdev_base

ENV INSTALLDIR=$INSTALLDIR
ENV HOST=$HOST
ENV PORT=$PORT

ADD ./conf/nginx.conf /etc/nginx/
ADD ./conf/phab.conf /etc/nginx/conf.d/
ADD ./conf/www.conf /etc/php/$PHPVER/fpm/pool.d/
ADD ./conf/00-phab.ini /etc/php/$PHPVER/fpm/conf.d/

# Allow www-data (entrypoint) to sudo as root to run nginx
RUN echo "www-data  ALL=(root)  NOPASSWD: /usr/sbin/nginx" >> /etc/sudoers && \
    echo "www-data  ALL=(root)  NOPASSWD: /usr/sbin/php-fpm$PHPVER" >> /etc/sudoers && \
    echo "www-data  ALL=(phab-phd)  NOPASSWD: ALL" >> /etc/sudoers && \
    echo "www-data  ALL=(root)  NOPASSWD: /usr/bin/sed" >> /etc/sudoers && \
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

ADD ./conf/local.json /opt/phabdev
ADD ./conf/entrypoint.sh /opt/phabdev

ENTRYPOINT ["/opt/phabdev/entrypoint.sh"]
