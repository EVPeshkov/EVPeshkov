#!/bin/bash

#Installing and configuring Nginx
apt install nginx -y
systemctl enable nginx.service
cp ./nginx-default-config /etc/nginx/sites-enabled/default
service nginx restart

#Installing and configuring Apache
apt install apache2 -y
systemctl enable apache2.service
cp ./apache-ports-config /etc/apache2/ports.conf
service apache2 restart

#Installing and configuring MySQL server
apt install mysql-server -y
systemctl enable mysql.service
cp /etc/mysql/mysql.conf.d/mysqld.conf /etc/mysql/mysql.conf.d/mysqld.conf.bak
cp ./apache-mysql-config /etc/mysql/mysql.conf.d/mysqld.conf
mysql --execute="create user replica@'80.78.243.9' identified if 'caching_sha2_password' BY 'OtusPeshkov24';"
mysql --execute="grant replication slave on *.* to replica@'80.78.243.9';"

#Installing and configuring agents
apt install prometeheus prometheus-node-exporter prometheus-apache-exporter prometheus-mysqld-exporter -y
systemctl enable --now prometheus-node-exporter
systemctl enable --now prometheus-apache-exporter
systemctl enable --now prometheus-mysqld-exporter

dpkg -i https://cdn.otus.ru/media/public/65/6d/filebeat_8.9.1_amd64-224190-656d53.deb
cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bak
cp ./apache-both-fbeats-config /etc/filebeat/filebeat.yml
systemctl enable --now filebeat.service


#Configuring network
cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak
cp ./apache-nginx-network /etc/netplan/00-installer-config.yaml
netplan apply
