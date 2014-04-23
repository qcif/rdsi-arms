```
title: How to migrate ARMS 1B records into a 2A instance
layout: page
tags: ['intro','configGuide']
pageOrder: 3
```
## Migrate ARMS 1B records into a 2A instance
The steps to migrate ARMS 1B records into a 2A instance is similar to those to restore in normal ReDBox. Some reference can be found [here on ReDBox site](http://www.redboxresearchdata.com.au/documentation/system-administration/general-administration/system-restore-or-migration).
The administrator of 1B instance will prepare `NODE_NAME.tar.gz` with all necessary files: `sequence.sql`, `restore_node.sh`, `change_owner.py`, solr indexes and records.
`sequence.sql` is node specified and the counter has to match to the node counter in 1B.  

0. Install 2A as described [here](http://qcif.github.io/rdsi-arms/pages/installation/).
0. Get the `NODE_NAME.tar.gz` from the operator of 1B instance.
0. Extract the content of tar.gz file into installation location. For example, under `/opt/redbox/`. You should see there are a few folders including `home`, `server`, `portal` and etc. 
0. Run command:
```shell
cd /opt/redbox/
sh restore_node.sh NODE_NAME
```
0. Start up ARMS for the first time.
0. Access ARMS from browser as usual. You will not see any record but you have to do it to ensure the system is fully up.
0. Go to server directory, e.g. `/opt/redbox/server`, run `./tf_restore.sh`
0. Once it is done, log in as a user having reviewer role to check if data has been restored successfully.
0. Update owner's token: 
  * have a user whose token will be mapped logging in to the system.
  * have the user clicking on user name that appears on the right of the menu bar. A popup should appear.
  * have the user copying the User ID and sending it to the node operator.
  * once node operator has the token,
     * update `tfOBJchanges` in `change_owner.py with user's token.
     * uncomment `tfOBJchanges = {"https ... `
     * delete line `tfOBJchanges = None`
     * `cp /opt/redbox/support/1B-2AMigration/change_owner.py /opt/redbox/storage/1793582ab247f6442162a75562dcc548`
     * `cd /opt/redbox/storage/1793582ab247f6442162a75562dcc548`
     * `rgrep owner= * | python change_owner.py`
     * repeat when another user's token needs to be mapped
