#!/bin/bash

# Install MySQL
# sudo yum install -y mysql-server
# sudo systemctl start mysqld.service
# sudo systemctl enable mysqld.service    
# mysql --connect-expired-password -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';"

# Install node
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs
node --version

# Move file from temp folder to opt folder
sudo mv /tmp/webappFork.zip /opt

# Unzip webapp folder
sudo yum install -y unzip
sudo unzip /opt/webappFork.zip -d /opt/webappFork

# Move service file from temp folder to etc folder
sudo mv /tmp/csye6225.service /etc/systemd/system

# Steps to create user csye6225
sudo adduser csye6225 --shell /usr/sbin/nologin
sudo chown -R csye6225:csye6225 /opt/webappFork

# Step to start service app
sudo systemctl daemon-reload
sudo systemctl enable csye6225.service