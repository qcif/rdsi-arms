import com.googlecode.fascinator.common.JsonSimple
import com.googlecode.fascinator.common.JsonObject
import org.json.simple.JSONArray
import org.apache.commons.io.FileUtils

def jsonArray = new JSONArray()
def nodes = project.properties["node.list"].split(",")
for(node in nodes) {
	def nodeDirectory = new File(project.properties["dir.portal"]+"/"+node)
	portalJsonFile = new File(nodeDirectory.getPath()+"/portal.json")
	if(portalJsonFile.exists()){
		node = loadJsonObject(portalJsonFile)
		portal = node.get("portal")
		nodeJson = new JsonObject()
		nodeJson.put("value", portal.get("name"))
		nodeJson.put("label", portal.get("displayName"))
		jsonArray.add(nodeJson)
	}
}

def nodesJsonFile = new File(project.properties["dir.portal"]+ "/default/rdsi/form-components/rdsi-nodes.json")
FileUtils.writeStringToFile(nodesJsonFile,jsonArray.toString())

def loadJsonObject(jsonFile) {
	def nodesJson = new JsonSimple(jsonFile)
	return nodesJson.getJsonObject()
}
