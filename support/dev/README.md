#Development server deployment

* Ensure you add the IP address and hostname to /etc/hosts
* Once httpd installed, update "ServerName" in httpd/conf/httpd.conf to your fqdn or ip address
* Consider also updating hostname of box (/etc/sysconfig/network and /etc/hosts)
* currently ipaddress is used for redbox and mint environments. To not show ipaddress (if DNS setup manually) change to dns name

Run these:

    sudo -s
    adduser --system -m redbox
    
    mkdir -p /opt/mint /opt/redbox /opt/deploy
    chown redbox:redbox /opt/*
    cd /home/redbox
    wget https://raw.github.com/qcif/rdsi-arms/master/support/dev/deploy.sh
    wget https://raw.github.com/qcif/rdsi-arms/master/support/dev/start_all.sh
    wget https://raw.github.com/qcif/rdsi-arms/master/support/dev/redbox.cron
    wget https://raw.github.com/qcif/rdsi-arms/master/support/dev/redbox-mint.sh
    wget https://raw.github.com/qcif/rdsi-arms/master/support/dev/apache
    chmod u+x *.sh
    
    chown -R redbox:redbox /home/redbox
    
    yum install java-1.7.0-openjdk
 	yum install httpd 

	mv /home/redbox/apache /etc/httpd/conf.d/25-redbox.conf

	service httpd restart
	
    cd /home/redbox
    ./start_all.sh

    cd /opt/mint/server
    sudo -u redbox ./tf_harvest.sh ANZSRC_FOR


##Scripts
* redbox.cron - a crontab file
* start_all.sh - initial startup of deploy.sh for redbox and mint, before cron is used.
* apache - the apache config
* redbox-mint.sh - a /etc/init.d/ script
* deploy.sh - takes 1 param (redbox | mint) and checks to see if there's a new deployment