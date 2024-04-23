#!/bin/bash

# Download and install Ops Agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

echo "-- Create folder structure for log file --"
sudo mkdir -p /var/log/webappLog

echo "-- Create log file --"
sudo touch /var/log/webappLog/webapp.log

echo "-- Copy config file to /tmp--"
sudo cp /tmp/config.yaml /etc/google-cloud-ops-agent/config.yaml

echo "-- Change ownership of log file --"
sudo chown -R csye6225:csye6225 /var/log/webappLog/webapp.log

echo "-- Restart Ops agent --"
sudo systemctl restart google-cloud-ops-agent