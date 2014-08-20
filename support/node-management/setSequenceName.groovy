// Replacing squence name with node specified

final String VM_PATH = "${portalDir}/default/rdsi/home-components/create-request.vm"

def processFileInplace(file, Closure processText) {
	def text = file.text
	file.write(processText(text))
}

// With a correct profile, node.list is a string with one node name  
// In case no profile is set, make sure we are not having a list
def nodes = "${nodeList}".split(",")
if(nodes.length > 1 ) {
	throw new Exception("Can only be used for creating one-node package. Check profile or project's node.list.");
}

def node = nodes[0]
def vm_file = new File(VM_PATH)
processFileInplace(vm_file) { text ->
	text.replaceAll(/@NODESEQUENCE@/, node)
}