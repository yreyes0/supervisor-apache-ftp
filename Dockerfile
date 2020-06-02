FROM centos:7.3.1611
MAINTAINER Oriol Boix Anfosso dev@orboan.com

# - Install basic packages (e.g. python-setuptools is required to have python's easy_install)
# - Install yum-utils so we have yum-config-manager tool available
# - Install inotify, needed to automate daemon restarts after config file changes
# - Install jq, small library for handling JSON files/api from CLI
# - Install supervisord (via python's easy_install - as it has the newest 3.x version)
RUN \
  yum update -y && \
  yum install -y epel-release && \
  yum install -y iproute python-setuptools hostname inotify-tools yum-utils which jq && \
  yum clean all && \

  easy_install supervisor

# - Updating system
# - Install some basic web-related tools...
RUN \ 
yum update -y && \ 
yum install -y wget patch tar bzip2 unzip openssh-clients MariaDB-client

#- Install HTTPD

RUN yum install -y httpd

#- Install Server FTP
RUN yum install -y vsftpd 


# - Colorize ls
RUN echo 'alias ls="ls --color"' >> ~/.bashrc \
&& echo 'alias ll="ls -lh"' >> ~/.bashrc \
&& echo 'alias la="ls -lha"' >> ~/.bashrc

# - Clean YUM caches to minimise Docker image size...
RUN \
  yum clean all && rm -rf /tmp/yum*

ENV USER=www
ENV PASSWORD=iaw

# - Add supervisord conf, bootstrap.sh files
ADD container-files /

RUN \
   sed -ri "s/www/${USER}/g" /etc/supervisord.conf && \
   sed -ri "s/iaw/${PASSWORD}/g" /etc/supervisord.conf

VOLUME ["/data"]

EXPOSE 22 9001

ENTRYPOINT ["/config/bootstrap.sh"]
