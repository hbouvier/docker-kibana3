FROM hbouvier/precise-chef
MAINTAINER henri bouvier

RUN locale-gen --no-purge en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN apt-get -y update
ADD . /chef

RUN cd /chef && /opt/chef/embedded/bin/berks install --path /chef/cookbooks
RUN chef-solo -c /chef/solo.rb -j /chef/solo.json 
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# To allow Docker -link configuration of ElasticSearch
RUN sed "s/9200/ES_PORT_9200_TCP_PORT/g" /etc/nginx/sites-enabled/kibana > /tmp/kibana
RUN sed "s/10.11.12.13/ES_PORT_9200_TCP_ADDR/g" /tmp/kibana > /etc/nginx/kibana.tpl

EXPOSE 80

CMD sed "s/ES_PORT_9200_TCP_PORT/$ES_PORT_9200_TCP_PORT/g" /etc/nginx/kibana.tpl > /tmp/kibana && sed "s/ES_PORT_9200_TCP_ADDR/$ES_PORT_9200_TCP_ADDR/g" /tmp/kibana > /etc/nginx/sites-enabled/kibana && cat /etc/nginx/sites-enabled/kibana && env && nginx
