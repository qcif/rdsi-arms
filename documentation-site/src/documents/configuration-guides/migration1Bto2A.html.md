```
title: How to migrate ARMS 1B records into a 2A instance
layout: page
tags: ['intro','configGuide']
pageOrder: 3
```
## Migrate ARMS 1B records into a 2A instance
The steps to migrate ARMS 1B records into a 2A instance is similar to those to restore in normal ReDBox. Some reference can be found [here on ReDBox site](http://www.redboxresearchdata.com.au/documentation/system-administration/general-administration/system-restore-or-migration).

0. Install 2A as described [here](../documentation-site/src/documents/pages/installation.html.md).
0. Get the tar.gz file which contains `sequence.sql`, solr indexes and records from the operator of 1B instance.
0. Extract the content of tar.gz file into installation location. For example, under `/opt/redbox/`. You should see there are a few folders including `home`, `server`, `portal` and etc. 

  *Some notes*:
  * To be safe, it is recommended to remove `solr` and `storage` directories if they exist before extracting.
  * Make sure ARMS is not running. 
0. Run command:
```shell
cd /opt/redbox/
sh restore_node.sh NODE_NAME
```
  *Some notes*:
  * If above command returns error, it might be **org.apache.derby.tools.ij** is not installed. It can be downloaded from [here](http://db.apache.org/derby/derby_downloads.html). The direct link of the [library](http://mirror.ventraip.net.au/apache//db/derby/db-derby-10.8.3.0/db-derby-10.8.3.0-lib.tar.gz). The instructions for installation (e.g. extract and set environment variables) is [here](http://db.apache.org/derby/papers/DerbyTut/install_software.html#derby).
  * ARMS has to be not running.
0. Startup ARMS for the first time.
0. Access ARMS from browser as normal. You will not see any record but you have to do it to ensure the system is fully up.
0. Go to server directory, e.g. `/opt/redbox/server`, run `./tf_restore.sh`
0. Log in as a user having reviewer role to check if data has been restored successfully in the portal.
0. Update owner's token: 
  * have a user who created records to log in to the system.
  * ask user to click on user name that appears on the right of the menu bar. A popup should appear.
  * user copies the User ID and send it to the node operator.
  * once node operator has the token, 
     * updates `tfOBJchanges` in `/opt/redbox/support/1B-2AMigration/change_owner.py with user's token.
     * uncomments `tfOBJchanges = {"https ... `
     * deletes line `tfOBJchanges = None`
     * `cp /opt/redbox/support/1B-2AMigration/change_owner.py /opt/redbox/storage/1793582ab247f6442162a75562dcc548`
     * `cd /opt/redbox/storage/1793582ab247f6442162a75562dcc548`
     * `rgrep owner= * | python change_owner.py`
     * repeat when another user's token needs to be mapped
