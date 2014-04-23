-- Prepared by 1B administrator for a node by:
-- 1. connect to 1B database and get the node's counter
-- 2. replace NODE_NAMERequest with correct value: e.g. ersaRequest, two instances
-- 3. replace 1000 to the number should be used
-- 4. put this file into NODE_NAME.tar.gz with resotore.sh, solr/ and storage/
-- This file is unique for every node
-- This only works with the standard installation location: /opt/redbox/ 
connect 'jdbc:derby:/opt/redbox/home/database/fascinator';
INSERT INTO sequences SELECT 'NODE_NAMERequest', 0 FROM sequences HAVING count(*)=0;
UPDATE SEQUENCES SET COUNTER=1000 WHERE SEQUENCENAME='NODE_NAMERequest';
disconnect;
exit;
