import com.googlecode.fascinator.common.JsonSimple
import com.googlecode.fascinator.common.JsonObject
import org.apache.commons.io.FileUtils

def nodes = "${nodeList}".split(",")
def systemConfigFile = new File("${homeDir}/system-config.json")
def systemConfig = new JsonSimple(systemConfigFile)
def systemConfigObject = systemConfig.getJsonObject()
def packageTypes = systemConfigObject.get("portal").get("packageTypes")
for(node in nodes) {
	packageType = new JsonObject()
	packageType.put("jsonconfig","arms-" +node+".json")
	packageType.put("packages-in-package",false)
	packageTypes.put("arms-"+node,packageType)
}
FileUtils.writeStringToFile(systemConfigFile,systemConfig.toString(true))

