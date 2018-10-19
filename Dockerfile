FROM centos:7

ENV container docker
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8


RUN rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch 
RUN echo $'[curator-5] \n\
name=CentOS/RHEL 7 repository for Elasticsearch Curator 5.x packages \n\
baseurl=https://packages.elastic.co/curator/5/centos/7 \n\ 
gpgcheck=1 \n\
gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch \n\
enabled=1 \n'\
> /etc/yum.repos.d/curator.repo

RUN yum install -y elasticsearch-curator

RUN mkdir -p /etc/curator/

RUN echo $'client: \n\
  hosts: ELASTIC_HOSTS \n\
  port: ELASTIC_PORT \n\
  url_prefix: \n\
  use_ssl: False \n\
  certificate: \n\
  client_cert: \n\
  client_key: \n\
  ssl_no_validate: False \n\
  http_auth: HTTP_AUTH \n\
  timeout: 30 \n\
  master_only: False \n\
  \n'\
  > /etc/curator/config.yml

RUN echo $'actions \n\
  1: \n\
    action: act1 \n\
    description: Test \n\
\n'\
> /etc/curator/action.yml

RUN echo $'#!/bin/bash \n\
sed -i "s/ELASTIC_HOSTS/$ELASTIC_HOSTS/g" /etc/curator/config.yml \n\
sed -i "s/ELASTIC_PORT/$ELASTIC_PORT/g" /etc/curator/config.yml \n\
sed -i "s/HTTP_AUTH/$HTTP_AUTH/g" /etc/curator/config.yml \n\
echo "updated variables in config"\n\
if [ "$DEBUG" == "true" ] \n\
then \n\
	cat /etc/curator/config.yml \n\
	echo "\n script\n" \n\
	cat /etc/curator/start_script.sh \n\
	echo "\n repo \n" \n\
	cat /etc/yum.repos.d/curator.repo\n\
	echo "\n action \n" \n\
	cat "$ACTION_FILE" \n\
fi \n\
i=$LOOP_COUNT \n\
while [ $i -ne 0 ] \n\
do \n\
	if [ "$DEBUG" == "true" ] \n\
	then \n\
		echo "$i loops left of $LOOP_COUNT" \n\
	fi \n\
	if [ "$CONFIG" == "" ] \n\
	then \n\
		if [ "$DEBUG" == "true" ] \n\
		then \n\
			echo "running /usr/bin/curator $ACTION_FILE $CURATOR_ARG" \n\	
		fi \n\
		/usr/bin/curator $ACTION_FILE $CURATOR_ARG \n\	
	else \n\
		if [ "$DEBUG" == "true" ] \n\
		then \n\
			echo "running /usr/bin/curator --config $CONFIG $CURATOR_ARG $ACTION_FILE" \n\
		fi \n\
		/usr/bin/curator --config $CONFIG $CURATOR_ARG $ACTION_FILE \n\
	fi \n\
	if [ $i -ge 0 ] \n\
	then \n\
		i=$[$i-1] \n\
	fi \n\
	sleep $SLEEP_DELAY \n\
done \n'\
> /etc/curator/start_script.sh

ENV DEBUG="false"

ENV LOOP_COUNT=-1

ENV SLEEP_DELAY=3600

ENV ACTION_FILE="/etc/curator/action.yml"

ENV CONFIG="/etc/curator/config.yml"

ENV CURATOR_ARG=""

ENV ELASTIC_HOSTS="127.0.0.1"

ENV ELASTIC_PORT="9200"

ENV HTTP_AUTH=""

RUN chmod a+x /etc/curator/start_script.sh

RUN chmod -R 777 /etc/curator/

USER nobody:nobody 

ENTRYPOINT "/etc/curator/start_script.sh"

