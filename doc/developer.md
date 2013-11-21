#Developer

##Building
This guide describes how to build a copy of the ARMS codebase. At completion of this guide you will have a packaged version of the system that can then be deployed onto a server.

###Prerequisites
This guide assumes that you are comfortable with Apache Maven and Git. Before commencing this guide you need to ensure that you have the following software installed on your system:

* The Java JDK 1.7
  *Oracle's JDK (http://www.oracle.com/technetwork/java/javase/downloads/index.html) or
  * Open JDK (http://openjdk.java.net/install/index.html)
* Apache Maven 2.2.1 (http://maven.apache.org/download.cgi)
* Maven 3 may compile fine but the deployed system WILL NOT WORK PROPERLY
* Git (http://git-scm.com/downloads)

###Step-by-step guide - packaging
```bash
mkdir arms
cd arms
git clone https://github.com/qcif/redbox-rdsi.git src
cd src
mvn clean package -Pbuild-package
```

A .tar.gz file will be created in the target directory - this is what you'll deploy to a server.
Once you have completed the step above, please refer to 02 - Installing ARMS

###Step-by-step guide - developers
 If you're developing the code it is better to run the commands listed below. This deploys a local copy of the system in the arms/ directory.
```bash
mkdir arms
cd arms
git clone https://github.com/qcif/redbox-rdsi.git src
cd src
mvn clean install
```

As the ARMS system is a profile of the ReDBox system you should familiarise yourself with the ReDBox documentation: <http://www.redboxresearchdata.com.au/>

##Installing ARMS
This guide describes how to install the ARMS system on a clean Ubuntu Server 12.04.3 LTS.

Whilst these instructions are for Ubuntu, the system can run on a variety of platforms, with Linux being the primary preference.

Please be aware that this guide does not describe how to install ARMS in a production environment. This is purely a basic install guide.

###Step-by-step guide
The first stage will be to install the ARMS software:

1. Copy the deployment package created in Building to the appropriate server
1. Untar the package in an appropriate deployment directory (e.g /opt)
	1. tar xvzf xxxx.tar.gz
    1. A redbox/ directory is created
1. Go to the server/ directory
   1. Edit tf_env.sh to reflect your system setup
   1. Run sudo ./tf.sh start to start the system
   1. The system will be available at http://<ip/domain>:9000/redbox

Next, install the Mint system (this provides lookups for vocabularies such as the Field of Research)

1. Download the Mint software:
	1. wget http://dev.redboxresearchdata.com.au/nexus/content/repositories/releases/com/googlecode/redbox-mint/mint-local-curation-demo/1.6.2/mint-local-curation-demo-1.6.2-build.tar.gz
1. Untar the package in an appropriate directory (e.g. /opt)
   1. A mint/ directory is created 
1. Check the configuration in mint/server/tf_env.sh to ensure it matches your settings
    1. Mint only needs to run on localhost - it isn't accessed remotely
1. Start the Mint service
	1. sudo ./tf.sh start
1. Import the Field of Research codes:
./tf_harvest.sh ANZSRC_FOR

At this point you should be able to access the ARMS system and start creating records. 

A set of default user/passwords have been created in the system:

* admin/rbadmin
* user/user
* reviewer/reviewer
* committee/approver
* provisioner/provisioner

###Follow-up
Once you've got the default system running, you may want to look at 03 - Configuring ARMS.
The system will now be running on a non-standard port for web browsers. If you wish to make the system accessible via the standard Port 80, use of Apache HTTP with mod_proxy (http://httpd.apache.org/docs/2.2/mod/mod_proxy.html) is suggested.

##Configuring ARMS
The ARMS system is based on ReDBox and a lot of useful documentation for the system can be found at http://www.redboxresearchdata.com.au/documentation. Key documentation items include:

* System layout: <http://www.redboxresearchdata.com.au/documentation/system-administration/general-administration/system-layout>
* Branding: <http://www.redboxresearchdata.com.au/documentation/system-administration/general-administration/branding>
* The workflow and forms configuration: <http://www.redboxresearchdata.com.au/documentation/how-to/setup-a-new-workflow>
* In-depth info about the configuration file: <https://sites.google.com/site/fascinatorhome/home/documentation/technical/configuration>

ARMS provides a notifications system that can send emails at various times. This has not yet been configured for QCIF but the documentation should assist those wishing to enable notifications: <http://www.redboxresearchdata.com.au/documentation/how-to/how-to-setup-an-email-trigger>