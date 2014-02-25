import com.googlecode.fascinator.common.JsonSimple
import com.googlecode.fascinator.common.JsonObject
import org.json.simple.JSONArray
import org.apache.commons.io.FileUtils
import org.apache.commons.lang.StringUtils
import groovy.util.logging.*


final String RDSI_NODES_PATH = project.properties["dir.portal"]+ "/default/rdsi/form-components/rdsi-nodes.json"
 
def jsonArray = new JSONArray()
def nodes = project.properties["node.list"].split(",")
for(node in nodes) {
	def nodeDirectory = new File(project.properties["dir.portal"]+"/"+node)
	log.debug 'node directory:'+ nodeDirectory;
	portalJsonFile = new File(nodeDirectory.getPath()+"/portal.json")
	log.debug 'portalJson file:'+ portalJsonFile;
	if(portalJsonFile.exists()){
		nodeConfig = loadJsonObject(portalJsonFile)
		nodePortalConfig = nodeConfig.get("portal") 		
		nodeJson = createJsonNode(nodePortalConfig, node)
		jsonArray.add(nodeJson)
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
	nodeJson = new JsonObject()
	if (StringUtils.equalsIgnoreCase(node, "qcif")) {
		nodeJson.put("value", "QCIF-BNE")
		nodeJson.put("label", "QCIF-BNE")
		nodeJson.put("value", "QCIF-TSV")
		nodeJson.put("label", "QCIF-TSV")
	} else {
		nodeJson.put("value", nodePortalConfig.get("name"))
		nodeJson.put("label", nodePortalConfig.get("displayName"))
	}
	return nodeJson
}