FROM ubuntu:14.04
MAINTAINER Niclas Björner <niclas@cromigon.se>

# No tty available
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade

# Basic requirements
RUN apt-get -y install mysql-server mysql-client nginx php5-fpm php5-mysql pwgen python-setuptools curl git php5-cli php5-mcrypt

# MySQL Config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# nginx Config
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# php-fpm Config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# nginx-site
ADD ./conf/nginx-site.conf /etc/nginx/sites-available/default

# Supervisor Config
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
ADD ./conf/supervisord.conf /etc/supervisord.conf

# Install msys
ADD https://github.com/bthstudent/msys/archive/master.tar.gz /usr/share/nginx/master.tar.gz
RUN cd /usr/share/nginx && tar xvzf master.tar.gz && rm master.tar.gz
RUN mv /usr/share/nginx/html/5* /usr/share/nginx/msys-master/public_html

# Installation and startup script
ADD ./script/init.sh /init.sh
RUN chmod 755 /init.sh

# Expose ports
EXPOSE 3306
EXPOSE 80

# Volume for mysql and msys
VOLUME ["/var/lib/mysql", "/usr/share/nginx/msys-master"]

# Run on startup
CMD ["/bin/bash", "/init.sh"]
