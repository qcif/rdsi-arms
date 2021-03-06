import os, sys, distutils.core, json
import solr, re

# Top working directory
storageDir = "storage/1793582ab247f6442162a75562dcc548"	

#def usage():
	#grep -rl jsonConfigPid=arms- storage/1793582ab247f6442162a75562dcc548/* | python filter_node.py ersa
	# copy to destinate
	# replace the content
	# grep -rl arms-ersa storage/ | xargs sed -i 's/arms-ersa/arms/'

def deleteEvent(s, filepath):
	packageRoots, packageID = splitMetaPath(filepath)
	print "id = %s will be used to query" % packageID
	s.delete_query("oid:%s" % packageID)

def printline(filepath):
	filepath = os.path.abspath(filepath.rstrip())
	print filepath
	dobjpath = os.path.dirname(filepath)
	if os.path.exists(dobjpath):
		print "Moving digital object: %s" %  dobjpath
	else:
		print "Cannot confirm the existence. Check the path: %s" % dobjpath
	print "\n"
	
def changeTFOBJMETA(filePath, changes):
	f = open(filePath)
	lines = f.readlines()
	f.close()
	with open(filePath, 'w') as outfile:
		for l in lines:
			#print changeLine(l,changes),
			outfile.write(changeLine(l,changes))
		outfile.close()

def changeLine(line, changes):
	keys = changes.keys()
	parts = line.split("=")
	if parts[0] in changes:
		line = "%s=%s\n" % (parts[0], changes[parts[0]])
	return line

def splitMetaPath(metaPath):
	packagePath, tf_obj_meta = os.path.split(metaPath)
	# return a list with packageRoots and packageID
	return os.path.split(packagePath)	
	
def copyPackage(metaPath, targetDir):
	packagePath, tf_obj_meta = os.path.split(metaPath)
	print "Copy package %s%s to %s" % (workingDir, packagePath, targetDir)
	# make the strucutre
	packageRoots, packageID = os.path.split(packagePath)	
	dirs = buildPackagePath(packagePath)
	r = targetDir
	for d in dirs:
		r = os.path.join(r,d)
		print "Ensuring the existence of %s\n" % r
		ensureCreated(r)
	print "Copytree %s to %s\n\n" % (os.path.join(workingDir, packagePath), os.path.join(targetDir,r))
	#shutil.copytree(os.path.join(workingDir, packagePath), os.path.join(targetDir,r))
	dstDir = os.path.join(targetDir,r)
	if not os.path.exists(os.path.join(dstDir, packageID)):
		try:
			distutils.dir_util.copy_tree(os.path.join(workingDir, packagePath), dstDir)
		except Error as err:
			print "Copy tree failed. More %s" % err
	return dstDir

def buildPackagePath(rawPath):
	parts = rawPath.split("/")
	cleaned = []
	for part in parts:
		if part:
			cleaned.append(part)
	return cleaned

def ensureCreated(dirPath):
	print "Checking %s" % dirPath
	if not os.path.exists(dirPath):
		os.makedirs(dirPath)

def changeWorkflowMeta(filePath):
	f = open(filePath)
	d = json.loads(f.read())
	f.close()
	#print d
	
	d["id"] = "arms"
	d["step"] = workflowchanges["step"][d["step"]] # if no step can be mapped, error
	if d["label"] in workflowchanges["label"]:
		d["label"] = workflowchanges["label"][d["label"]]
	
	with open(filePath, 'w') as outfile:
		json.dump(d, outfile)
		outfile.close()

def setEnv(argv):
	print argv
	global workingDir, nodeName, savingDir
	workingDir = os.getcwd()
	nodeName = argv[0]
	savingDir = os.path.join(workingDir, nodeName)
	print "Filtering %s/%s for %s" % (workingDir, storageDir, nodeName)	
	print "Copy resulting packages to %s\n" % savingDir	

def getFilesWithFields(path):
	## fields are only in 'version' and 'tfpackage' files
	filePatternForFields = '.*version_[\d]+$|.*tfpackage$'
	## get absolute pathnames for only files under directory
	absPaths = [os.path.join(path,filename) for filename in next(os.walk(path))[2]]
	pattern = re.compile(filePatternForFields)
	fileMatches = [f for f in absPaths if pattern.match(f)]
	print "Files that contain fields : %s" % fileMatches
	return fileMatches

def changeFields(fields, files):
	for nextFile in files:
		f = open(nextFile, 'r+')
		data = f.read()

		## data can contain mixed codecs - problematic for json.loads - search/replace instead.
		for (original, updated) in fields.iteritems():
			data = data.replace(original,updated)
			print "replaced %s with %s in %s" % (original, updated, nextFile)
		f.seek(0)
        f.write(data)
        f.truncate()
        f.close()


def swapFieldValues(fields, files):
	mask = '(\s*:\s*)("[\w-]*?")'
	for nextFile in files:
		f = open(nextFile, 'r+')
		data = f.read()

		for (swap1, swap2) in fields.iteritems():
			match1 = re.search('(\"' + swap1 + '\")' + mask, data, re.S|re.M)
			match2 = re.search('(\"' + swap2 + '\")' + mask, data, re.S|re.M)
		
			if (match1 and match2):
				key1 = match1.group(1)
				key2 =  match2.group(1)
				delimiter1 = match1.group(2)
				delimiter2 = match2.group(2)
				value1 =  match1.group(3)
				value2 =  match2.group(3)
			
				print "swapping %s%s%s with %s%s%s" % (key1,delimiter1,value1,key2,delimiter2,value2)
				data = data.replace(key1+delimiter1+value1, key1+delimiter1+value2,1)
				data = data.replace(key2+delimiter2+value2, key2+delimiter2+value1,1)
		f.seek(0)
        f.write(data)
        f.truncate()
        f.close()

if __name__ == "__main__":
	setEnv(sys.argv[1:])
	ensureCreated(savingDir)

	# find . -name simpleworkflow-rules.py
	# find . -name arms.json
	# This works for arms-2b-restore
	tfOBJchanges = {"jsonConfigOid":"80cc5098405912038038ba7d4c746443","jsonConfigPid":"arms.json","rulesOid":"5986552442302d50fc55bb36e72578cf"}
	workflowchanges = {"id":"arms","step":{"arms-request":"arms-draft","arms-submitted":"arms-review"},"label":{"Submitted":"Being reviewed"}}	
	fieldChanges = {"dataprovider:authority":"dataprovider-authority","collection-details-audience":"storage-geographic-distribution-audience","request:declarations.1":"request-declarations.1","request:declarations.2":"request-declarations.2"}
	## currently this is set for migration for qcif node - TODO: adjust so can be used for all nodes - perhaps mapping nodeName to numbers in list that correspond to correct node.
	fieldSwaps = {"storage-location.5":"storage-location.2","storage-location.4":"storage-location.1","storage-location:prefLabel.5":"storage-location:prefLabel.2","storage-location:prefLabel.4":"storage-location:prefLabel.1"}

	# create a connection to a solr server
	s = solr.SolrConnection('http://127.0.0.1:9000/solr/eventlog')

	for p in sys.stdin:
		print p
		(filePath, pattern) = p.split(":")
		#print "Filepath=%s, pattern=%s" % (filePath, pattern)
		if pattern.find(nodeName) > 0:
			print "Filter out for %s" % nodeName
			printline(p)
			packagePath = copyPackage(p, savingDir)
			#print "Working dir is: %s" % packagePath

			changeTFOBJMETA(os.path.join(packagePath,"TF-OBJ-META"),tfOBJchanges)
			changeWorkflowMeta(os.path.join(packagePath,"workflow.metadata"))
	
			filesWithFields = getFilesWithFields(packagePath)
			changeFields(fieldChanges, filesWithFields) 
			swapFieldValues(fieldSwaps, filesWithFields) 
		else:
			print "Related event of %s will be removed because type=%s" % (os.path.basename(filePath), pattern)
			deleteEvent(s, filePath)
	
	#s.commit()
