#!/bin/bash

# Connect with droplet/vm ip
ssh -i ~/.ssh/digitalocean root@vm_ip
mkdir newdir
ls -a

# Install MySQL
sudo yum install mysql-server -y
sudo systemctl start mysqld.service
mysql --connect-expired-password -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root@1234';"
mysql -u root -p
CREATE DATABASE dbname;

# Install node
sudo dnf module list nodejs
sudo dnf module enable nodejs:20
sudo yum install -y nodejs
node --version

# Unzip File
sudo yum install unzip
unzip_filename.zip
npm install
node index.js

# SCP files to vm folder
# Go to folder path
scp -i ~/.ssh/digitalocean .env root@64.23.167.57:/home/node
scp -i ~/.ssh/digitalocean vaishnavi_choukwale_002816622_02-2.zip root@64.23.167.57:/home/node

# clone repo
$ git clone url
$ git checkout -b branchName
npm i

# checkout code to git branch
$ git checkout demoBranch
$ git add .
$ git commit -m "updated yml file to test workflow failure"
$ git push origin demoBranch
