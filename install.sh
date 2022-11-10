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

which java &>/dev/null
if [ $? -ne 0 ]; then 
	## Downloading Java
	#DownloadJava 8
	## Installing Java
	#apt-get install /opt/jdk* -y &>/dev/null
	apt-get install java -y &>/dev/null
	if [ $? -eq 0 ]; then 
		success "JAVA Installed Successfully"
	else
		error "JAVA Installation Failure!"
		exit 1
	fi
else
	success "Java already Installed"
fi




## Downloading SonarQube 
#VER=$(curl -s https://sonarsource.bintray.com/Distribution/sonarqube/  | tail -n 10 | awk -F '[<,>]' '{print $5}' | grep zip$ |tail -1)
#URL="https://sonarsource.bintray.com/Distribution/sonarqube/$VER"
#URL=$(curl -s https://www.sonarqube.org/downloads/ |grep zip | grep btn-primary | tail -1 | awk -F \" '{print $2}')
#URL=$(curl -s https://www.sonarqube.org/downloads/ |grep zip | grep btn-download | grep free | awk -F \" '{print $4}')
URL=$(curl -s https://www.sonarqube.org/downloads/ |grep zip | grep 'Community Edition' | grep -v btn-download | head -1 | awk -F '"' '{print $2}')
TFILE="/opt/$(echo $URL |awk -F / '{print $NF}')"
TDIR=$(echo $TFILE|sed -e 's/.zip//')
rm -rf /opt/sonarqube
wget $URL -O $TFILE &>/dev/null
cd /opt
unzip $TFILE &>/dev/null
mv $TDIR sonarqube 
if [ $? -eq 0 ]; then
	success "Successfully Downloaded and Extracted SonarQube"
else
	error "Error in Downlading and Extracting SonarQube"
	exit 1
fi

## Configure SonarQube
sed -i -e '/^sonar.jdbc.username/ d' -e '/^sonar.jdbc.password/ d' -e '/^sonar.jdbc.url/ d' -e '/^sonar.web.host/ d' -e '/^sonar.web.port/ d' /opt/sonarqube/conf/sonar.properties
sed -i -e '/#sonar.jdbc.username/ a sonar.jdbc.username=sonarqube' -e '/#sonar.jdbc.password/ a sonar.jdbc.password=password' -e '/InnoDB/ a sonar.jdbc.url=jdbc:mysql://localhost:3306/sonarqube?useUnicode=true&amp;characterEncoding=utf8&amp;rewriteBatchedStatements=true&amp;useConfigs=maxPerformance' -e '/#sonar.web.host/ a sonar.web.host=0.0.0.0' /opt/sonarqube/conf/sonar.properties

useradd sonar
chown sonar:sonar /opt/sonarqube -R
sed -i -e '/^#RUN_AS_USER/ c RUN_AS_USER=sonar' /opt/sonarqube/bin/linux-x86-64/sonar.sh
ln -s /opt/sonarqube/bin/linux-x86-64/sonar.sh /etc/init.d/sonar
systemctl enable sonar &>/dev/null 
systemctl start sonar &>/dev/null
if [ $? -eq 0 ]; then
	success "Configured and Started SonarQube Successfully"
else
	error "SonarQube Startup Failed"
	exit 1
fi
