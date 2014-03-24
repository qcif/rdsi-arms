# Configuring ARMS

**Under construction...**


## Configuring local username and password authentication

### Method 1: Web user interface

1. Login as a user with the _admin_ role.

2. Click on the "Admin" menu and choose "Security".

3. Edit users and roles.

### Method 2: Editing config files

1. Edit the /opt/redbox/home/security/users.properties file.

     The format is username = hashed-password.

2. Edit the /opt/redbox/home/security/roles.properties

      The format is username = comma separated set of roles.

3. Restart the ARMS ReDBox so the changes are read.


## Configuring AAF authentication

### Step 1. Install and configure Shibboleth

1. Make sure _/etc/hosts_ has correct entry.

2. Install _shibd_

            \# CentOS 6.x:
            cd /etc/yum.repos.d
            wget http://download.opensuse.org/repositories/security://shibboleth/CentOS_CentOS-6/security:shibboleth.repo
            yum install shibboleth.x86_64

            \# Debian:
            sudo apt-get install libapache2-mod-shib2

3. Prepare certification:
   with correct host name set previously, the installation of shibboleth creates default /etc/shibboleth/sp-cert.pem which is ready for use for the registration of service provider with AAF. Otherwise run:

            cd /etc/shibboleth
            ./keygen.sh -f -h fqdn.site.name -e http(s)://fqdn.site.name/shibboleth

### Step 2. Register with AAF as a service provider

1. Go to <https://manager.test.aaf.edu.au/federationregistry/registration/sp>.

     Note: All fields have help information on the form.

2. Section 1. Primary Contact: fill in your information

3. Section 2. Service Provider Description:

       1. Pickup ReDBox Research Data as Organisation
       2. Fill in a descriptive string as Display Name
       3. Fill in a brief description for this service
       4. Fill in Service URL with server's name or IP address

4. Section 3. SAML Configuration:

      The latest Shibboleth installation version should be 2.4 above
      so click Shibboleth Service Provider (2.4.x) radio button in
      "Easy registration using defaults" section.  For URL fill in the
      value filled in above Service URL field. Do not touch other
      fields in "Advanced SAML 2 registration" if default end points
      and other settings are used.

      1. Section 4. Public Key Certificate:

           Copy the content of /etc/shibboleth/sp-cert.pem and paste
           it into Certificate field. After paste, the form will
           validate it. If you see Status Valid above the text box,
           than it is a good certificate.

      2. Section 5. Requested Attributes:

           Select attributes: eduPersonTargetedID, commonName,
           displayName, eduPersonAffiliation,
           eduPersonScopedAffiliation, email, organizationName.

           You need to make up reasons for requiring them.

      3. Submit

      4. While waiting for a response from AAF, configure shibboleth:

           a. Download AAF metadata signing certificate: wget wget https://ds.test.aaf.edu.au/distribution/metadata/aaf-metadata-cert.pem -O /etc/shibboleth/aaf-metadata-cert.pem

           b. Copy mapping file into /etc/shibboleth (support/shibboleth/attribute-map.xml)

           c. Edit /etc/shibboleth/shibboleth2.xml:

     i. Replace all instances of sp.example.org with IP address or FQDN

		ii.edit <Sessions> element: set attributes of handlerSSL="false" and cookieProps="http" in <Sessions> element. Of course, if SSL has been configured, do otherwise suggested by AAF

		iii.special to ReDBox: add this attributePrefix="AJP_" to  element <ApplicationDefaults>. It should look like this: <ApplicationDefaults entityID="your_entityID" REMOTE_USER="eppn persistent-id targeted-id" attributePrefix="AJP_">

		iv. Edit `<MetadataProvider>` element to suit `test.aaf`

        <MetadataProvider type="XML" uri="https://ds.test.aaf.edu.au/distribution/metadata/metadata.aaf.signed.complete.xml" backingFilePath="metadata.aaf.xml" reloadInterval="7200">    
          <MetadataFilter type="RequireValidUntil" maxValidityInterval="2419200"/>    
          <MetadataFilter type="Signature" certificate="aaf-metadata-cert.pem"/>
        </MetadataProvider>

        v. Edit `<SSO>` (Session Initiator) element:

              1. Delete entityID attribute
              2. Set discoveryURL: discoveryURL="https://ds.test.aaf.edu.au/discovery/DS"

        vi.save

           d. Restart shibd by running: (sudo) `service shibd restart`
		
### Step 3. Configure Apache

By default, ReDBox's SSO Shibboleth uses this location: /default/sso/shibboleth. Mark it to hook up with Shibboleth: 

    <Location /redbox/default/sso/shibboleth>
      AuthType shibboleth
      ShibRequireSession On
      require valid-user
    </Location>

Note: above location is used when
/redbox/config/src/main/config/server/jetty/contexts/fascinator.xml
defines "contextPath" = /redbox. If it is in other contextPath,
replace "/redbox" in `<Location>`.

ReDBox runs in a Jetty container, to use Apache as its front end, reverse proxy have to be used:

    ProxyPass /redbox/ ajp://localhost:8009/redbox/
    ProxyPassReverse /redbox/ ajp://localhost:8009/redbox/

Note: When contextPath is not /redbox, especially it is root: "/",
special treats have to be given to Shibboleth related locations. Two
lines below tell Apache do not proxy to Jetty container.  Remember: if
these two lines have to be used, they have to be above normal reverse
proxy directives list above.

    ProxyPassMatch /Shibboleth !
    ProxyPass /default/sso/shibbloeth !

### Step 4. Check your SP status and settings

On the server:

    wget http://localhost/Shibboleth.sso/Status

If you had no error and had a file Status saved to your current directory and having reasonable XML contents: certs and etc. you know it has been set up correctly.
In browser (with default setting, you only see error messages, but as long as it produced by Shibboleth like this: opensaml::BindingException, setting should be OK)

    http://site/Shibboleth.sso/SAML2/Artifact
    http://site/Shibboleth.sso/SAML2/POST

Some times, in case of test federation, its IdP can stop updating or does not return your entry metadata, you have to contact AAF.

### Step 5. Production Federation

Useful links:

 - To manage: <https://manager.aaf.edu.au/federationregistry/dashboard/index>
 - To see all options: <https://manager.aaf.edu.au/federationregistry/>
 - To register a service provider: <https://manager.aaf.edu.au/federationregistry/registration/sp>

As describe above but with a few differences.

1. Assuming HTTPS will be used, so always use https instead of http
   when protocol is needed either when registering or configuring

2. Download production AAF metadata signing certificate:

        wget https://ds.aaf.edu.au/distribution/metadata/aaf-metadata-cert.pem -O /etc/shibboleth/aaf-metadata-cert.pem

3. Insert production MetadataProvider

4. Use

        <MetadataProvider type="XML" uri="https://ds.aaf.edu.au/distribution/metadata/metadata.aaf.signed.complete.xml"
         backingFilePath="metadata.aaf.xml" reloadInterval="7200">
          <MetadataFilter type="RequireValidUntil" maxValidityInterval="2419200"/>
          <MetadataFilter type="Signature" certificate="aaf-metadata-cert.pem"/>
        </MetadataProvider>

5. Use default `<Session>` attributes: aka. make sure
`handlerSSL="true"` and `cookieProps="https"` are set.

6. Edit <SSO> element:

     1. Delete entityID attribute
     2. Set discoveryURL: `discoveryURL="https://ds.aaf.edu.au/discovery/DS"`


## Email notifications

### Configurations

Email notifications can be sent when a request changes state.

Email configurations are found in
`/opt/redbox/home/process/emailer.json`.  Restart ReDBox after editing
this configuration file.

The top level fields are:

- host: SMTP server address
- port: SMTP server port number (usually port 25)
- username: identity to use for SMTP server
- password: authentication to use for SMTP server
- tls: secure SMTP
- ssl: secure SMTP
- SubmissionNotifier: email templates

Fields for SubmissionNotifier are:

- from: emails will appear to come from this email address
- to: comma separated list of destination email addresses
- subject: subject for the email
- body: contents for the email
- vars:
- mapping:

Note: The requestor's email address is obtained from the value entered
on the request form.  Email addresses from the user's AAF credentials
are not used by ARMS.

### Sending frequency

ARMS sends the notification emails at periodic intervals.

The interval is set in `/opt/redbox/home/system-config.json`.
Restart ReDBox after editing this configuration file.

The interval is set by the `houseKeeping` "process-set-all" job
`timing`.

For example, the following sets it to once every minute:

    "timing": "1 * * * * ?"


## See also

- Other [documentation](README.md) for ARMS.