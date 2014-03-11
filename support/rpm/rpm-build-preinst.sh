#!/usr/bin/env bash
## Create redbox user and group if they have not been created
if ! type "/etc/init.d/redbox" > /dev/null; then
  service redbox stop
fi

## Remove old library
if [ -d /opt/redbox/server/lib ]; then
	rm -rfv /opt/redbox/server/lib
fi
if [ -d /opt/redbox/server/plugins ]; then
	rm -rfv /opt/redbox/server/plugins
fi