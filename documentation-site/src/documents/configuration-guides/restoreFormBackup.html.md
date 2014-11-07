```
title: Restore data from a backup
layout: page
tags: ['intro','configGuide']
pageOrder: 4
```
## Restore data from a backup
The steps to restore a system backup is similar to those documented [here on ReDBox site](http://www.redboxresearchdata.com.au/documentation/system-administration/general-administration/system-restore-or-migration).
Here we assume the backup will be restored to the same server so there is no need to change user tokens saved in records.
 
0. It is recommended to remove `home/logs` before restoring. If preferred, remove exiting installation completely and install a new instance.
0. Get the backup package: a tar.gz file which should contain `sequence.sql`, solr indexes and records.
0  Extract the content of the package into installation directory: e.g `/opt/redbox`.
0. Run command:
```shell
cd /opt/redbox/
# Do not be confused by the location of restore_node.sh. It can be used for a general purpose.
wget https://raw.githubusercontent.com/qcif/rdsi-arms/master/support/1B-2AMigration/restore_node.sh
sh restore_node.sh TAR.GZ.NAME
```
  *Some notes*:
  * ARMS has to be not running.
  * TAR.GZ.NAME is the part of the backup package before .tar.gz, e.g. for 20140419.tar.gz, it should be 20140419.
0. Now, start up ARMS for the first time.
0. Access ARMS from browser as usual. You will not see any record but you have to do it to ensure the system is fully up.
0. In system-config.json, turn off email notification.
0. Go to server directory, e.g.:
```shell
cd /opt/redbox/server
./tf_restore.sh
```
0. In system-config.json, turn back on email notification.
0. Once it is done, log in as a user having reviewer role to check if data has been restored successfully.
