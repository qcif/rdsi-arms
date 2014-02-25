# Deploying ARMS

## For puppet : follow support/puppet/README for redbox and shibboleth
 
 OR 

1. Follow README.md under support/dev for redbox install

2. For setting up AAF login:

1. install shibboleth and configure it
a. make sure /etc/hosts has correct entry
b. install shibd on CentOS 6:
	cd /etc/yum.repos.d
	wget http://download.opensuse.org/repositories/security://shibboleth/CentOS_CentOS-6/security:shibboleth.repo
	yum install shibboleth.x86_64

	Or on Debian:
	sudo apt-get install libapache2-mod-shib2
c.prepare certification:
   with correct host name set previously, the installation of shibboleth creates default /etc/shibboleth/sp-cert.pem which is ready for use for the registration of service provider with AAF. Otherwise run:  cd /etc/shibboleth/; ./keygen.sh -f -h fqdn.site.name -e http(s)://fqdn.site.name/shibboleth

2. register as a service provider with AAF. All fields have help information on the form.
	a.go to https://manager.test.aaf.edu.au/federationregistry/registration/sp
	b.Section 1. Primary Contact: fill in your information
	c. Section 2. Service Provider Description:
		i.pickup ReDBox Research Data as Organisation
		ii.fill in a descriptive string as Display Name
		iii.fill in a brief description for this service
		iv. fill in Service URL with server's name or IP address
	d.Section 3. SAML Configuration:
	 the latest shibboleth installation version should be 2.4 above so click Shibboleth Service Provider (2.4.x) radio button in "Easy registration using defaults" section.  For URL fill in the value filled in above Service URL field. Do not touch other fields in "Advanced SAML 2 registration" if default end points and other settings are used.
	e. Section 4. Public Key Certificate:
		copy the content of /etc/shibboleth/sp-cert.pem and paste it into Certificate field. After paste, the form will validate it. If you see Status Valid above the text box, than it is a good certificate.
	f.Section 5. Requested Attributes:
	select attributes: eduPersonTargetedID, commonName, displayName, eduPersonAffiliation, eduPersonScopedAffiliation, email, organizationName. You need to make up reasons for requiring them
	g.submit
3.when waiting for response from AAF, configure shibboleth:
	a.download AAF metadata signing certificate: wget wget https://ds.test.aaf.edu.au/distribution/metadata/aaf-metadata-cert.pem -O /etc/shibboleth/aaf-metadata-cert.pem
	b.copy mapping file into /etc/shibboleth (support/shibboleth/attribute-map.xml)
	c.edit /etc/shibboleth/shibboleth2.xml: 
		i.replace all instances of sp.example.org with IP address or FQDN
		ii.edit <Sessions> element: set attributes of handlerSSL="false" and cookieProps="http" in <Sessions> element. Of course, if SSL has been configured, do otherwise suggested by AAF
		iii.special to ReDBox: add this attributePrefix="AJP_" to  element <ApplicationDefaults>. It should look like this: <ApplicationDefaults entityID="your_entityID" REMOTE_USER="eppn persistent-id targeted-id" attributePrefix="AJP_">
		iv. edit <MetadataProvider> element to suit test.aaf  
		<MetadataProvider type="XML" uri="https://ds.test.aaf.edu.au/distribution/metadata/metadata.aaf.signed.complete.xml" backingFilePath="metadata.aaf.xml" reloadInterval="7200">    
			<MetadataFilter type="RequireValidUntil" maxValidityInterval="2419200"/>    
			<MetadataFilter type="Signature" certificate="aaf-metadata-cert.pem"/>                             
		</MetadataProvider>
		v.edit <SSO> (Session Initiator) element:
		  - delete entityID attribute
		  - set discoveryURL: discoveryURL="https://ds.test.aaf.edu.au/discovery/DS"
		vi.save
	d. restart shibd by running: (sudo) service shibd restart
		
3. Set up Apache
By default, ReDBox's sso Shibboleth uses this location: /default/sso/shibboleth. Mark it to hook up with Shibboleth: 
<Location /redbox/default/sso/shibboleth>
    AuthType shibboleth
    ShibRequireSession On
    require valid-user
</Location>

Note, above location is used when /redbox/config/src/main/config/server/jetty/contexts/fascinator.xml defines "contextPath" = /redbox. If it is in other contextPath, replace "/redbox" in <Location>. 

ReDBox runs in a Jetty container, to use Apache as its front end, reverse proxy have to be used:

ProxyPass /redbox/ ajp://localhost:8009/redbox/
ProxyPassReverse /redbox/ ajp://localhost:8009/redbox/

Note: When contextPath is not /redbox, especially it is root: "/", special treats have to be given to Shibboleth related locations. Two lines below tell Apache do not proxy to Jetty container.
Remember: if these two lines have to be used, they have to be above normal reverse proxy directives list above.
ProxyPassMatch /Shibboleth !
ProxyPass /default/sso/shibbloeth !

4. Check your SP status and settings:
On the server
wget http://localhost/Shibboleth.sso/Status

If you had no error and had a file Status saved to your current directory and having reasonable XML contents: certs and etc. you know it has been set up correctly.
In browser (with default setting, you only see error messages, but as long as it produced by Shibboleth like this: opensaml::BindingException, setting should be OK)
	http://site/Shibboleth.sso/SAML2/Artifact
	http://site/Shibboleth.sso/SAML2/POST
Some times, in case of test federation, its IdP can stop updating or does not return your entry metadata, you have to contact AAF.

5. Production Federation
Useful links:
	to manage: https://manager.aaf.edu.au/federationregistry/dashboard/index
	to see all options: https://manager.aaf.edu.au/federationregistry/
	to register a service provider: https://manager.aaf.edu.au/federationregistry/registration/sp

As describe above but with a few differences.
1. assuming HTTPS will be used, so always use https instead of http when protocol is needed either when registering or configuring
2. download production AAF metadata signing certificate: wget https://ds.aaf.edu.au/distribution/metadata/aaf-metadata-cert.pem -O /etc/shibboleth/aaf-metadata-cert.pem
3. insert production MetadataProvider
4. <MetadataProvider type="XML" uri="https://ds.aaf.edu.au/distribution/metadata/metadata.aaf.signed.complete.xml"
     backingFilePath="metadata.aaf.xml" reloadInterval="7200">
     <MetadataFilter type="RequireValidUntil" maxValidityInterval="2419200"/>
     <MetadataFilter type="Signature" certificate="aaf-metadata-cert.pem"/>
	</MetadataProvider>
5. use default <Session> attributes: aka. make sure handlerSSL="true" and cookieProps="https" are set
6. edit <SSO> element:
	i. delete entityID attribute
	ii. set discoveryURL: discoveryURL="https://ds.aaf.edu.au/discovery/DS"



## Deploying from Nexus

The following describes the steps performed by the _install-arms.sh_ script.

### 1. Obtain installation files

Obtain the installation files from GitHub. These commands do not have
to be run with root privileges: the files can be stored anywhere and
can be owned by any user.

In this example, they are placed in `/tmp/install-arms`:

    mkdir /tmp/install-arms
    cd /tmp/install-arms

    curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/deploy.sh
    curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/apache
    chmod a+x deploy.sh

   
### 2. Install Java and Apache

Note: steps 2 and onwards need to be run with root privileges. This
can be done by either prefacing every command with _sudo_.

For RHEL-based Linux distributions (e.g. CentOS), use _yum_ to install Java and Apache.

    yum install java-1.7.0-openjdk
    yum install httpd

### 3. Create the redbox user and group

Create a _redbox_ user account, as a system user (i.e. no aging
information in /etc/shadow and numeric identifiers are in the system
user range and no home directory).

    adduser --system redbox

### 4. Create directories to install services in
    
    mkdir -p /opt/mint /opt/redbox
    chown redbox:redbox /opt/mint /opt/redbox


### 5. Configure and run Apache

a. Copy the configuration for ReDBox into Apache's configuration directory.

    cp apache /etc/httpd/conf.d/25-redbox.conf

b. Set the _ServerName_ in Apache's configuration file.
Find the commented entry for _ServerName_ and change it to the fully
qualified domain name (or IP address) for the server. For example,
`ServerName arms.example.com:80`.

    vi /etc/httpd/conf/httpd.conf


c. Start Apache.

    service httpd start

Test Apache by running `service httpd status`.

### 6. Install ReDBox and Mint

    su redbox -c "./deploy.sh redbox"
    su redbox -c "./deploy.sh mint"

Check the log files (in _/opt/redbox/home/logs_ and
_/opt/mint/home/logs_) to ensure no errors were encountered.

### 7. Build Mint indexes

    cd /opt/mint/server
    sudo -u redbox ./tf_harvest.sh ANZSRC_FOR

TODO: the order should be changed so that mint is installed first,
then ReDBox and then Apache. Since that is the dependency order.