FROM ubuntu:22.04 as phabdev_base

RUN apt-get update && \
    apt-get upgrade -y

ENV DEBIAN_FRONTEND noninteractive

ENV PHPVER 8.2

RUN apt-get install -y sudo netcat-traditional iputils-ping ca-certificates software-properties-common apt-transport-https && \
    apt-get install -y mariadb-client nginx && \
    apt-get install -y --no-install-recommends ssh && \
    apt-get install -y git mercurial && \
    apt-get install -y vim less ripgrep fd-find && \
    apt-get install -y nodejs && \
    apt-get install -y --no-install-recommends npm && \
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
ADD ./conf/phab-fpm.conf /etc/php/$PHPVER/fpm/pool.d/
ADD ./conf/phab.sshd_config /etc/ssh/sshd_config.d/
ADD ./conf/phabricator-ssh-hook.sh /usr/libexec/

RUN ln -s /usr/lib/git-core/git-http-backend /usr/bin/

# Allow www-data (entrypoint) to sudo as root to run nginx
RUN echo "www-data  ALL=(root)  NOPASSWD: /usr/sbin/nginx" >> /etc/sudoers.d/phab-sudoers && \
    echo "www-data  ALL=(root)  NOPASSWD: /usr/sbin/php-fpm$PHPVER" >> /etc/sudoers.d/phab-sudoers && \
    echo "www-data  ALL=(phab-phd)  NOPASSWD: ALL" >> /etc/sudoers.d/phab-sudoers && \
    echo "www-data  ALL=(root)  NOPASSWD: /usr/bin/sed" >> /etc/sudoers.d/phab-sudoers && \
    echo "www-data  ALL=(root)  NOPASSWD: /usr/sbin/sshd" >> /etc/sudoers.d/phab-sudoers && \
    echo "www-data  ALL=(root)  NOPASSWD: /usr/bin/rm /var/tmp/aphlict/pid/aphlict.pid" >> /etc/sudoers.d/phab-sudoers && \
    echo "phab-phd  ALL=(root)  NOPASSWD: ALL" >> /etc/sudoers.d/phab-sudoers && \
    echo "wanderer  ALL=(phab-phd)  SETENV: NOPASSWD: /usr/bin/hg, /usr/bin/git, /usr/bin/git-upload-pack, /usr/bin/git-upload-archive, /usr/bin/git-receive-pack, /usr/bin/git-http-backend" >> /etc/sudoers.d/phab-sudoers

RUN useradd --system phab-phd && \
    groupadd phab && \
    usermod -a -G phab phab-phd && \
    usermod -a -G phab www-data

# The user which accepts incoming SSH
RUN useradd --system --create-home --shell /usr/bin/bash wanderer && \
    usermod -a -G phab wanderer && \
    usermod -p NP wanderer

RUN mkdir -p /opt/phabdev/ && \
    mkdir -p /opt/filestore && \
    mkdir -p /opt/repos && \
    mkdir -p /var/log/phabricator && \
    mkdir -p /run/php/ && \
    mkdir -p /run/sshd/ && \
    touch /var/log/aphlict.log && \
    touch /var/log/phab-ssh-error.log && \
    touch /var/log/php-error.log

RUN chown -R phab-phd:phab  /opt/ && \
    chown -R www-data:phab  /var/log/phabricator/ && \
    chown -R www-data:phab  /var/www/ && \
    chown    www-data:phab  /var/log/aphlict.log && \
    chmod -R g+rws  /opt/ && \
    chmod -R g+rws  /var/log/phabricator/ && \
    chmod -R 0755   /run/sshd/ && \
    chmod    g+rw   /var/log/aphlict.log && \
    chmod    g+rw   /var/log/phab-ssh-error.log && \
    chown    www-data:phab  /var/log/php-error.log

# Run entrypoint as the web service account
USER www-data

ADD ./conf/local.json /opt/phabdev
ADD ./conf/entrypoint.sh /opt/phabdev

ENTRYPOINT ["/opt/phabdev/entrypoint.sh"]
