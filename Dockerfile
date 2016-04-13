FROM      ubuntu
MAINTAINER Olexander Kutsenko <olexander.kutsenko@gmail.com>

#install
RUN export LC_ALL=C
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y software-properties-common python-software-properties
RUN apt-get install -y git git-core vim nano mc nginx screen curl unzip zip wget
RUN apt-get install -y apache2-utils tmux apt-transport-https

#Install PHP
RUN apt-get install -y wget php5 php5-fpm php5-cli php5-common php5-intl
RUN apt-get install -y php5-json php5-mysql php5-gd php5-imagick
RUN apt-get install -y php5-curl php5-mcrypt php5-dev php5-xdebug
RUN rm /etc/php5/fpm/php.ini
COPY configs/php.ini /etc/php5/fpm/php.ini
COPY configs/nginx/default /etc/nginx/sites-available/default

# SSH service
RUN apt-get install -y openssh-server openssh-client
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
#change 'pass' to your secret password
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> sudo tee -a /etc/profile

#configs bash start
COPY configs/autostart.sh /root/autostart.sh
RUN chmod +x /root/autostart.sh
COPY configs/bash.bashrc /etc/bash.bashrc

#Add colorful command line
RUN echo "force_color_prompt=yes" >> ~/.bashrc
RUN echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'" >> .bashrc

#etcKeeper
RUN mkdir -p /root/etckeeper
COPY configs/etckeeper.sh /root
COPY configs/etckeeper-hook.sh /root/etckeeper
RUN /root/etckeeper.sh


#Install Java 8
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update
# Accept license non-iteractive
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer
RUN apt-get install -y oracle-java8-set-default
RUN echo "JAVA_HOME=/usr/lib/jvm/java-8-oracle" | sudo tee -a /etc/environment
RUN export JAVA_HOME=/usr/lib/jvm/java-8-oracle


#Install Elasticsearch
RUN wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
RUN echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
RUN apt-get update
RUN apt-get -y install elasticsearch
RUN echo "network.host: localhost" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
RUN echo "MAX_MAP_COUNT=" | sudo tee -a /etc/default/elasticsearch
RUN service elasticsearch restart

#Install Kibana
RUN echo "deb http://packages.elastic.co/kibana/4.4/debian stable main" | sudo tee -a /etc/apt/sources.list.d/kibana-4.4.x.list
RUN apt-get update
RUN apt-get -y install kibana
RUN echo 'server.host: localhost' | sudo tee -a /opt/kibana/config/kibana.yml
RUN service kibana start
RUN htpasswd -b -c /etc/nginx/htpasswd.users admin admin
RUN service nginx restart

#Generate SSL Certificates
RUN mkdir -p /etc/pki/tls
RUN mkdir -p /etc/pki/tls/private/
RUN mkdir -p /etc/pki/tls/certs
RUN sed -i 's/# Extensions for a typical CA/subjectAltName = IP: 127.0.0.1/g' /etc/ssl/openssl.cnf
RUN openssl req -config /etc/ssl/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout /etc/pki/tls/private/logstash-forwarder.key -out /etc/pki/tls/certs/logstash-forwarder.crt


#Install Logstash
RUN echo 'deb http://packages.elastic.co/logstash/2.2/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash-2.2.x.list
RUN apt-get update
RUN apt-get install logstash -y
COPY configs/logstash/* /etc/logstash/conf.d/
RUN service logstash configtest
RUN service logstash start
RUN service elasticsearch start

RUN service elasticsearch restart
RUN service filebeat restart
RUN service logstash restart
#open ports
EXPOSE 80 22 5044 9200
