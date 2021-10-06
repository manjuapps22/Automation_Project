#!/bin/bash

apt update -y


myname='manjunath'
s3_bucket='upgrad-manjunath'
timestamp=$(date '+%d%m%Y-%H%M%S')

if [ $(dpkg --list | grep apache2 | cut -d ' ' -f 3 | head -1) == 'apache2' ]
then
	echo "Apache2 is installed...checking for its state"
	if [[ $(systemctl status apache2 | grep disabled | cut -d ';' -f 2) == ' disabled' ]];
		then
			systemctl enable apache2
			echo "Apache2 enabled now"
			systemctl start apache2

		else
			if [ $(systemctl status apache2 | grep active | cut -d ':' -f 2 | cut -d ' ' -f 2) == 'active' ]
			then
				echo "Apache2 is already running"
			else
				systemctl start apache2
				echo "Apache2 service started"
			fi
	fi
					
else
	echo "Apache2 not installed...will be installed now"
	printf 'Y\n' | apt-get install apache2
	echo "Apache2 service was installed"
	
fi

tar -zvcf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log


if [ $(dpkg --list | grep awscli | cut -d ' ' -f 3 | head -1) == 'awscli' ]

	then
		aws s3 \
		cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
		s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

	else
	echo "awscli is not present, installing now..."	
	printf 'Y\n' | apt install awscli
	aws s3 \
	cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
	s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

fi
