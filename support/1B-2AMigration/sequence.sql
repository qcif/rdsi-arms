connect 'jdbc:derby:/home/li/redbox-dev/restore_test/redbox/home/database/fascinator';
INSERT INTO sequences SELECT 'defaultRequest', 0 FROM sequences HAVING count(*)=0;
UPDATE SEQUENCES SET COUNTER=102 WHERE SEQUENCENAME='defaultRequest';
disconnect;
exit;
