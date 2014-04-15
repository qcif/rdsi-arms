import os, sys

# Replace users' token
#
# usage:
# cd /opt/redbox/storage/1793582ab247f6442162a75562dcc548
# rgrep owner= * | python change_owner.py
	
def changeTFOBJMETA(filePath, changes):
	f = open(filePath)
	lines = f.readlines()
	f.close()
	with open(filePath, 'w') as outfile:
		for l in lines:
			outfile.write(changeLine(l,changes))
	outfile.close()

def changeLine(line, changes):
	k = line.rstrip()
	if k.startswith('owner'):
		owner = k[6:]
		print "Checking %s" % owner
		if owner in changes:
			print"replace %s by %s\n" % (owner, changes[owner])
			line = "owner=%s\n" % changes[owner]
		else:
			print "%s does not match?\n" % k
	return line

if __name__ == "__main__":
	# replace tokens with existing 1B token from arms.rdsi.edu.au to new ones generated from a node instance
	# example is: { "old_token":"new_token" }
	# tfOBJchanges = {"https\://idp1\!https\://arms.rdsi.edu.au/shibboleth\!fYQMMUWCtJS7cWLa81Q0rTgKjMY\=":"newidp1token",
	#                 "urn\:mace\:federation.org.au\:testfed\:ipd2\!https\://arms.rdsi.edu.au/shibboleth\!kaPTnY+AnoHuTYW7epY1oh39rbU\=":"newtoken2"}
	
	tfOBJchanges = None
	
	if tfOBJchanges is None:
		print "Error: token map is not defined.\n\t Please edit change_owner.py to provide a token map."
		exit(1)

	for p in sys.stdin:
		filePath, pattern = p.split('TF-OBJ-META:')
		changeTFOBJMETA(os.path.join(filePath,"TF-OBJ-META"),tfOBJchanges)
