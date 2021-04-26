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

# Bookkeeping

mysize=$(stat -c%s /tmp/${myname}-httpd-logs-$timestamp.tar)
if [ -f /var/www/html/inventory.html ] 
then
 echo '<br> httpd-logs' >> /var/www/html/inventory.html
 echo '&ensp;' $timestamp >> /var/www/html/inventory.html
 echo '&ensp;' 'tar' >> /var/www/html/inventory.html
 echo '&emsp;' $mysize 'Bytes'>> /var/www/html/inventory.html
else
 touch /var/www/html/inventory.html
 echo "<!DOCTYPE html>
<html>
   <head></head>
   <body>
      <header>
<b>Date &emsp;&emsp;&emsp;
Created &emsp;&emsp;&emsp;&emsp;
Type &ensp;
Size</b>
  </header>
   </body>
</html>
" >> /var/www/html/inventory.html
 echo '<br> httpd-logs' >> /var/www/html/inventory.html
 echo '&ensp;' $timestamp >> /var/www/html/inventory.html
 echo '&ensp;' 'tar' >> /var/www/html/inventory.html
 echo '&emsp;' $mysize 'Bytes'>> /var/www/html/inventory.html
fi

# Installing awscli

 apt update
 apt -y install awscli

#Copy to s3 bucket
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

#Create cron job

if [ -f /etc/cron.d/automation ]
then 
	echo "Updating Cron Job"
        echo -n "" > /etc/cron.d/automation
	echo "36 1 * * * root /root/Automation_Project/automation.sh" >> /etc/cron.d/automation
	crontab /etc/cron.d/automation
	echo "Done"
else
	touch /etc/cron.d/automation
	echo "New Cron Job is creating"
	echo "36 1 * * * root /root/Automation_Project/automation.sh" >> /etc/cron.d/automation
	crontab /etc/cron.d/automation
	echo "Done"
fi

