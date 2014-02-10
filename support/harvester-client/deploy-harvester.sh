su redbox
cd /home/redbox
curl -L -o arms1a-arms2a-harvester-client.zip "http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=au.com.redboxresearchdata&a=arms-xml-harvester-client&v=LATEST&c=bin-console&e=zip"
unzip arms1a-arms2a-harvester-client.zip -d arms1a-arms2a-harvester-client
cd arms1a-arms2a-harvester-client
mkdir input
wget https://raw.github.com/qcif/rdsi-arms/master/support/harvest-client/data-for-2A.xml -O input/data-for-2A.xml
chmod +x harvest.sh