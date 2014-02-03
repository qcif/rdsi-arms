#Development server deployment

* Ensure you add the IP address and hostname to /etc/hosts
* Once httpd installed, update "ServerName" in httpd/conf/httpd.conf to your fqdn or ip address

Run these:
    sudo adduser --system -m redbox
    
    sudo mkdir -p /opt/mint /opt/redbox /opt/deploy
    sudo chown redbox:redbox /opt/*
    cd /home/redbox
    sudo wget https://raw.github.com/qcif/rdsi-arms/master/support/dev/deploy.sh
    sudo wget https://raw.github.com/qcif/rdsi-arms/master/support/dev/start_all.sh
    sudo wget https://raw.github.com/qcif/rdsi-arms/master/support/dev/redbox.cron
    sudo wget https://raw.github.com/qcif/rdsi-arms/master/support/dev/redbox-mint.sh
    sudo wget https://raw.github.com/qcif/rdsi-arms/master/support/dev/apache
    sudo chmod u+x *.sh
    
    sudo chown -R redbox:redbox /home/redbox
    
    sudo yum install java-1.7.0-openjdk
 	sudo yum install httpd 

	sudo mv /home/redbox/apache /etc/httpd/conf.d/25-redbox.conf

	service httpd restart
	
    cd /home/redbox
    sudo ./start_all.sh

    cd /opt/mint/server
    sudo -u redbox ./tf_harvest.sh ANZSRC_FOR


##Scripts
* redbox.cron - a crontab file
* start_all.sh - initial startup of deploy.sh for redbox and mint, before cron is used.
* apache - the apache config
* redbox-mint.sh - a /etc/init.d/ script
* deploy.sh - takes 1 param (redbox | mint) and checks to see if there's a new deployment