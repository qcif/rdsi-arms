import com.googlecode.fascinator.common.JsonSimple
import com.googlecode.fascinator.common.JsonObject
import org.apache.commons.io.FileUtils

def nodes = project.properties["node.list"].split(",")
def systemConfigFile = new File(project.properties["dir.home"]+"/system-config.json")
def systemConfig = new JsonSimple(systemConfigFile)
def systemConfigObject = systemConfig.getJsonObject()
def packageTypes = systemConfigObject.get("portal").get("packageTypes")
def packageType = new JsonObject()
for(node in nodes) {
	packageType.put("jsonconfig","arms-" +node+".json")
	packageType.put("packages-in-package",false)
	packageTypes.put("arms-"+node,packageType)
}
FileUtils.writeStringToFile(systemConfigFile,systemConfig.toString(true))

