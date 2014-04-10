## Migrate ARMS 1B records into a 2A instance
The steps to migrate ARMS 1B records into a 2A instance is similar to those to restore in normal ReDBox. Some reference can be found [here on ReDBox site](http://www.redboxresearchdata.com.au/documentation/system-administration/general-administration/system-restore-or-migration).

0. Install 2A as described [here](../documentation-site/src/documents/pages/installation.html.md).
0. Get the tar.gz file which contains `sequence.sql`, solr indexes and records from the operator of 1B instance.
0. Extract the content of tar.gz file into installation location. For example, under `/opt/redbox/`. You should see there are a few folders including `home`, `server`, `portal` and etc. 

  *Some notes*:
  * To be safe, it is recommended to remove `solr` and `storage` directories if they exist before extracting.
  * Make sure ARMS is not running. 
0. Reset sequence seed using following commands:
```shell
cd /opt/redbox/
wget http://mirror.ventraip.net.au/apache//db/derby/db-derby-10.8.3.0/db-derby-10.8.3.0-lib.tar.gz
tar zxf db-derby-10.8.3.0-lib.tar.gz
#java org.apache.derby.tools.ij sequence.sql
java -classpath db-derby-10.8.3.0-lib:db-derby-10.8.3.0-lib/lib/derbytools.jar org.apache.derby.tools.ij sequence.sql
```
  *Some notes*:
  * If above command returns error, it might be **org.apache.derby.tools.ij** is not installed. It can be downloaded from [here](http://db.apache.org/derby/derby_downloads.html). The direct link of the [library](http://mirror.ventraip.net.au/apache//db/derby/db-derby-10.8.3.0/db-derby-10.8.3.0-lib.tar.gz). The instructions for installation (e.g. extract and set environment variables) is [here](http://db.apache.org/derby/papers/DerbyTut/install_software.html#derby).
  * ARMS has to be not running.
  * `sequence.sql` assumed the installation is under `/opt/redbox/'; otherwise, change it accordingly.
0. Startup ARMS for the first time.
0. Access ARMS from browser as normal. You will not see any record but you have to do it to ensure the system is fully up.
0. Go to server directory, e.g. `/opt/redbox/server`, run `./tf_restore.sh`
0. Log in as a user having reviewer role to check if data has been restored successfully in the portal.
