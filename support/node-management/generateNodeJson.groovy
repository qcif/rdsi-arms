import com.googlecode.fascinator.common.JsonSimple
import com.googlecode.fascinator.common.JsonObject
import org.json.simple.JSONArray
import org.apache.commons.io.FileUtils
import org.apache.commons.lang.StringUtils
import groovy.util.logging.*


final String RDSI_NODES_PATH = project.properties["dir.portal"]+ "/default/rdsi/form-components/rdsi-nodes.json"

def jsonArray = new JSONArray()
def nodes = project.properties["node.list"].split(",")


addToNodeArray= {value, label->
	nodeJson = new JsonObject()
	nodeJson.put("value", value)
	nodeJson.put("label", label)
	jsonArray.add(nodeJson)
}

for(node in nodes) {
	def nodeDirectory = new File(project.properties["dir.portal"]+"/"+node)
	log.debug 'node directory:'+ nodeDirectory;
	portalJsonFile = new File(nodeDirectory.getPath()+"/portal.json")
	log.debug 'portalJson file:'+ portalJsonFile;
	if(portalJsonFile.exists()){
		nodeConfig = loadJsonObject(portalJsonFile)
		nodePortalConfig = nodeConfig.get("portal") 		
		createJsonNode(nodePortalConfig, node)	
	}
}

def nodesJsonFile = new File(RDSI_NODES_PATH)
String logMessage = new StringBuilder("Adding array: ")
	.append(jsonArray)
	.append("to file: ")
	.append(RDSI_NODES_PATH)
	.toString()
log.info(logMessage)
FileUtils.writeStringToFile(nodesJsonFile,jsonArray.toString())

def loadJsonObject(jsonFile) {
	def nodesJson = new JsonSimple(jsonFile)
	return nodesJson.getJsonObject()
}

def createJsonNode(nodePortalConfig, node) {
	if (StringUtils.equalsIgnoreCase(node, "qcif")) {
		["QCIF-BNE" : "QCIF-BNE", "QCIF-TSV" : "QCIF-TSV"].each(addToNodeArray)
	} else {
		def name = nodePortalConfig.get("name")
		def value = nodePortalConfig.get("displayName")
		addToNodeArray(name, value)
	}
}