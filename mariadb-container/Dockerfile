FROM mariadb

RUN apt-get -y update && apt-get -y upgrade && apt-get install -y \
    ca-certificates \
    openssl

RUN export PRECD=$(pwd) && mkdir -p /etc/phab-db/ssl/ && cd /etc/phab-db/ssl/ && \
    openssl genrsa 4096 > ca-key.pem && \
    openssl rsa -in ca-key.pem -out ca-key.pem && \
    openssl req -x509 -key ca-key.pem -sha256 -days 3650 -nodes -out ca.pem \
      -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname" && \
    openssl req -newkey rsa:4096 -keyout server-key.pem -sha256 -days 3650 -nodes -out server-req.pem \
      -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname" && \
    openssl rsa -in server-key.pem -out server-key.pem && \
    openssl x509 -req -in server-req.pem -days 3650 -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem && \
    cd $PRECD && \
    chown mysql -R /etc/phab-db

ADD ./conf/00-phab-mysql.cnf /etc/mysql/conf.d/

