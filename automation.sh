#!/bin/bash
SERVICE=apache2
myname=an
s3_bucket=upgrad-an
 
#Update the packet detail

 apt update -y

#Ensures that the HTTP Apache server is installed

if     dpkg -s $SERVICE 2>/dev/null >/dev/null
then
	echo "$SERVICE is already installed"

else
	echo "$SERVICE will be installed"
         apt-get update
         apt-get -y install $SERVICE

fi
#Ensure apache2 service is running

if service $SERVICE status | grep -q running
then
    echo "$SERVICE is running"
else
    echo "$SERVICE stopped"
     systemctl start $SERVICE
    echo "$SERVICE is starting"
     systemctl status $SERVICE
fi

#Ensure apache2 service is enabled

if service $SERVICE status | grep -q disable
then 
    echo "$SERVICE is disable"
     systemctl enable $SERVICE
    echo "$SERVICE is enabled"
     systemctl status $SERVICE

else
    echo "$SERVICE is enabled"
fi

#Enabling apache2 as a service ensures that it runs as soon as our machine reboots

 update-rc.d $SERVICE enable

#Tar Apache2 Log files

timestamp=$(date '+%d%m%Y-%H%M%S')
cd /var/log/apache2
 tar -cvf /tmp/${myname}-httpd-logs-$timestamp.tar *.log

# Installing awscli 
 apt update
 apt -y install awscli


#Copy to s3 bucket
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
