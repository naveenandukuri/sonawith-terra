#!/bin/bash
#sonarqube setup
sudo -i -u root << EOF
#install wget and unzip
sudo apt-get install unzip -y
#install java-11
sudo apt install openjdk-11-jre -y
cd /opt/
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.8.zip
sudo unzip sonarqube-7.8.zip
sudo useradd -m sonar && echo "sonar:sonar" | sudo chpasswd
# Run me with superuser privileges
sudo echo 'sonar  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers.d/sonar
sudo chown -R sonar:sonar /opt/sonarqube-7.8/
sudo chmod -R 775 /opt/sonarqube-7.8/
EOF
sudo -i -u sonar bash << EOF
cd /opt/sonarqube-7.8/bin/linux-x86-64/
./sonar.sh start
./sonar.sh status
EOF
