import com.googlecode.fascinator.common.JsonObject
import com.googlecode.fascinator.common.JsonSimple
import org.apache.commons.io.FileUtils
import org.apache.commons.lang.StringUtils
import org.json.simple.JSONArray

/*
Build node value and labels into rdsi-nodes.json. The local node should be at the top.
 */

final String RDSI_NODES_PATH = "${portalDir}/default/rdsi/form-components/rdsi-nodes.json"

def jsonArray = new JSONArray()
def nodes = "${nodeList}".split(",")


addToNodeArray= {value, label->
	nodeJson = new JsonObject()
	nodeJson.put("value", value)
	nodeJson.put("label", label)
	jsonArray.add(nodeJson)
}

for(node in nodes) {
	def nodeDirectory = new File("${portalDir}/"+node)
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
	// rdsi-nodes.json is now built from this list not portal.json.
	// nodePortalConfig.get("name"), nodePortalConfig.get("displayName") are not used.
	def valueList = ["eRSA" : "eRSA", "Intersect": "Intersect", "iVec": "iVec", "NCI":"NCI", "QCIF (Brisbane)":"QCIF (Brisbane)", "QCIF (Townsville)":"QCIF (Townsville)", "TPAC":"TPAC", "VicNode":"VicNode"]
	def mappings = [:] //use all lowcase names as portal names are in lowercase
	valueList.each { mappings[it.key.toLowerCase()] = it.key }

	if (StringUtils.equalsIgnoreCase(node, "qcif")) {
		["QCIF (Brisbane)" : "QCIF (Brisbane)", "QCIF (Townsville)": "QCIF (Townsville)"].each(addToNodeArray)
		valueList.remove("QCIF (Brisbane)")
		valueList.remove("QCIF (Townsville)")
	} else {
		addToNodeArray(mappings[node], valueList[mappings[node]])
		valueList.remove(mappings[node])
	}
	valueList.each(addToNodeArray)
}