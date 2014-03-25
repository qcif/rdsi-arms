#!/usr/bin/env bash

cp /opt/redbox/server/redbox /etc/init.d/redbox
chown root:root /etc/init.d/redbox
chmod 755 /etc/init.d/redbox

chkconfig --level 445 redbox on

service redbox restart

