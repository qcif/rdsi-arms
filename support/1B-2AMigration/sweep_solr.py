import sys, urllib2

# This script removes Solr indexes of tfpackages and attachments NOT belong to the current
# node but have not been filtered during the 1A migration.
# It does: 
#   1. gets a list of storage_id which do not belong to the node
#   2. runs a delete on fascinator through Solr API
#
# It has limited error detection and protection, so use with care

def remove_others(records):
    print "%d records will be removed" % len(records)
    confirmed = raw_input("Are you sure? [y/n] ")
    if confirmed != 'y':
        print "You chose no, no records will be removed"
        exit()

    # Replace this curl command with urllib2
    # curl http://localhost:9000/solr/fascinator/update?commit=true -H "Content-Type: text/xml" -d "<delete><query>storage_id:(31fad4a5fbdce93844cc5db421377a35 OR 603455f3147df570f5b7a99b90867666)</query></delete>"
    del_xml = "<delete><query>storage_id:(%s)</query></delete>" % " OR ".join(records)
    req = urllib2.Request('http://localhost:9000/solr/fascinator/update?commit=true', del_xml)
    req.add_header('Content-Type', 'text/xml')
    req.add_header('Content-Length', len(del_xml))
    response = urllib2.urlopen(req)
    print response.read()

if len(sys.argv) != 2:    
    print "Expecting one argument: node_name"
    exit()
    
working_node = sys.argv[1]
# Replace this solr query by urllib2
# wget  "http://localhost:9000/solr/fascinator/select/?q=-node%3ARDSI-ersa+AND+node%3A[*+TO+*]&version=2.2&start=0&rows=10000&indent=on&fl=storage_id&wt=csv" -O records.txt
response = urllib2.urlopen('http://localhost:9000/solr/fascinator/select/?q=-node%3ARDSI-' + working_node + '+AND+node%3A[*+TO+*]&version=2.2&start=0&rows=10000&indent=on&fl=storage_id&wt=csv')
records = response.read().split()

if records.pop(0) == 'storage_id':
	if len(records) > 0:
	    remove_others(records)
	else:
	    print "No records found. Nothing to do"
	    print "If doubt, double check with Solr manually"
else:
	print 'The solr query might have problem as storage_id is expected but not found'
	print records
	
