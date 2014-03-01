#!/usr/bin/env bash
## Create redbox user and group if they have not been created
if ! getent group redbox >/dev/null; then
	echo "Creating a group called redbox"
    groupdel redbox
fi

if ! getent passwd redbox >/dev/null; then
	echo "Creating a user called redbox"
    userdel redbox
fi

## Remove old library
if [ -d /opt/redbox/server/lib ]; then
	rm -rfv /opt/redbox/server/lib
fi
if [ -d /opt/redbox/server/plugins ]; then
	rm -rfv /opt/redbox/server/plugins
fi