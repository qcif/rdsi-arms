# Technical overview of ARMS

ARMS is a Web application which users access via a Web browser.
On the server side, ARMS consists of three main components:

- The ARMS ReDBox is the main component of ARMS. It is a customisation
  of the [ReDBox](http://www.redboxresearchdata.com.au) metadata
  registry application.

- [Mint](http://www.redboxresearchdata.com.au) is a name-authority and
  vocabulary service that complements ReDBox. In ARMS, Mint is used to
  provide ARMS with the Australian and New Zealand Standard Research
  Classification (ANZSRC) Field of Research (FoR) codes.

- An instance of the [Apache HTTP
  Server](http://projects.apache.org/projects/http_server.html) is
  used as a Web proxy to the ARMS ReDBox and Mint. It is used
  to provide TLS security.

ARMS ReDBox and Mint are implemented as [Jetty Web
servers](http://www.eclipse.org/jetty/); typically running on internal
ports 9000 and 9001 respectively. Apache listens on the standard port
443 for HTTPS (or 80 for HTTP) and redirects requests to those
internal ports.

ARMS has been designed to use the [Australian Authentication
Federation](http://aaf.edu.au) (AAF) to authenticate users. However,
for testing purposes a simple local username and password
authentication mechanism has been implemented.

## See also

- Other [documentation](README.md) for ARMS.