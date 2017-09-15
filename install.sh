#!/bin/bash

## Source Common Functions
curl -s "https://raw.githubusercontent.com/linuxautomations/scripts/master/common-functions.sh" >/tmp/common-functions.sh
#source /root/scripts/common-functions.sh
source /tmp/common-functions.sh

## Checking Root User or not.
CheckRoot

## Checking SELINUX Enabled or not.
CheckSELinux

## Checking Firewall on the Server.
CheckFirewall

## Downloading Java
DownloadJava 8

## Installing Java
yum localinstall $JAVAFILE -y &>/dev/null
if [ $? -eq 0 ]; then 
	success "JAVA Installed Successfully"
else
	error "JAVA Installation Failure!"
	exit 1
fi

## Downloading MYSQL Repositories and MySQL Server
MYSQLRPM=$(curl -s http://repo.mysql.com/ | html2text | grep el7 | tail -1 | sed -e 's/(/ /g' -e 's/)/ /g' | xargs -n1 | grep ^mysql)
MYSQLURL="http://repo.mysql.com/$MYSQLRPM"

if [ ! -f /etc/yum.repos.d/mysql-community.repo ]; then 

	yum install $MYSQLURL -y &>/dev/null
	if [ $? -eq 0 ]; then 
		success "Successfully Configured MySQL Repositories"
	else
		error "Error in Configuring MySQL Repositories"
		exit 1
	fi
else
	warning "MySQL Repositories are already Configured"
fi     

## Installing MySQL Server
yum install mysql-server -y &>/dev/null
if [ $? -eq 0 ]; then 
	success "Successfully Installed MySQL Server"
else
	error "Error in Installing MySQL Server"
	exit 1
fi

systemctl enable mysqld &>/dev/null
systemctl set-environment MYSQLD_OPTS="--skip-grant-tables"
systemctl start mysqld 
if [ $? -eq 0 ]; then 
	success "Successfully Started MySQL Server"
else
	error "Error in Starting MySQL Server"
	exit 1
fi

## Creating DB and User access
wget https://raw.githubusercontent.com/linuxautomations/sonarqube/master/sonarqube.sql -O /tmp/sonarqube.sql 
mysql </tmp/sonarqube.sql
if [ $? -eq 0 ]; then 
	success "Successfully Created DB and User access"
else
	error "Failed to create DB and User access"
	exit 1
fi

