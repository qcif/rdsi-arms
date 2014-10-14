import com.googlecode.fascinator.transformer.ScriptingTransformer
import com.googlecode.fascinator.common.FascinatorHome
import com.googlecode.fascinator.common.JsonSimple

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

emailingConfId = "MetafeedNotifier"
NotificationState="arms-provisioned"
IndicationField = "metadatafeed-notification"

// Send notifications to organisations listed in the contact section: 
//   dataprovider:organization, requester:organization or nodecontact:organization.
conf = ["dataprovider":[:],"requester":[:],"nodecontact":[:]]
//conf = ["dataprovider" : [
//	"org1":[["type": "MQ", "host":"11.xx.ss.xx","port":61613,"username":"user","passcode":"pass","queuename":"q"]],
//	"org2":[["type": "emailer"]],
//	"org":[["type": "MQ", "host":"11.xx.ss.xx","username":"user","passcode":"pass","queuename":"q"], ["type": "emailer"]]
//	],
//"requester": [
//	"org1":[["type": "MQ", "host":"11.xx.ss.xx","username":"user","passcode":"pass","queuename":"q"]],
//	"org2":[["type": "emailer"]],
//	"org":[["type": "MQ", "host":"11.xx.ss.xx","username":"user","passcode":"pass","queuename":"q"], ["type": "emailer"]]
//	],
//"nodecontact": [
//	"org1":[["type": "MQ", "host":"11.xx.ss.xx","username":"user","passcode":"pass","queuename":"q"]],
//	"org2":[["type": "emailer"]],
//	"org":[["type": "MQ", "host":"11.xx.ss.xx","username":"user","passcode":"pass","queuename":"q"], ["type": "emailer"]]
//	]
//]
// message queue host settings should like this
//	    "type": "MQ",
//	    "Host": "xxx.xxx.xxx.xxx",
//	    "Username": "arms",
//	    "Passcode": "pass",
//	    "QueueName": "name"

log = LoggerFactory.getLogger(ScriptingTransformer.class)

oid = digitalObject.getId()
payloads = digitalObject.getPayloadIdList()

if(payloads.contains("workflow.metadata")){
	def workflowMeta = new JsonSimple(digitalObject.getPayload("workflow.metadata").open());
	String workflow = workflowMeta.getString(null,"step")
	if (workflow == NotificationState) {
		log.debug(this.class.name + ": A transformer is set for current workflow - ${workflow}, actions may be taken.")
		def objMetadata = digitalObject.getMetadata()

		if (! objMetadata.getProperty(IndicationField)) {

			tfp = getTfPackage()
			dataprovider = tfp.getString(null,"dataprovider:organization")
			requester = tfp.getString(null,"requester:organization")
			nodecontact = tfp.getString(null,"nodecontact:organization")

//			log.debug("dataprovider:organization = ${dataprovider}")
//			log.debug("requester:organization = ${requester}")
//			log.debug("nodecontact:organization = ${nodecontact}")

			Class classDef = this.class.classLoader.parseClass(new File(FascinatorHome.getPath("transformer-scripts/") + "/NotificationAgent.groovy"))

			agent = classDef.newInstance()

			for (c in ["dataprovider", "requester", "nodecontact"]) {
				org = tfp.getString(null, c+":organization")
				if (conf[c] && conf[c].containsKey(org)) {
					log.debug(this.class.name + ": A ${c} notification for ${org} has been configured.")
					notifiers = conf[c][org]
					log.debug(notifiers.toString())
					for (s in notifiers) {
						notify(s)
					}
				} else {
					log.debug(this.class.name + ": There is no ${c} type of notification is set for ${org}.")
				}
			}

			objMetadata.setProperty(IndicationField, "true")
			// Set property in TF-OBJ-META
			ByteArrayOutputStream metaOut = new ByteArrayOutputStream();
			objMetadata.store(metaOut, "");
			InputStream metaIn = new ByteArrayInputStream(metaOut.toByteArray());
			digitalObject.updatePayload("TF-OBJ-META", metaIn);
			metaIn.close();
		} else {
			log.debug(this.class.name + ": ${IndicationField} has been set, skip")
		}
	} else {
		log.debug(this.class.name + ": No transfomer is set for current workflow - ${workflow}, so do nothing.")
	}
}

return digitalObject

// get TFPackage in JSON
def getTfPackage() {
	def tfPackage = null
	def tfPid = ""
	for (pid in digitalObject.getPayloadIdList()) {
		if (pid.endsWith(".tfpackage")){
			def payload = digitalObject.getPayload(pid)
			tfPackage = new JsonSimple(payload.open())
		}
	}
	return tfPackage
}

void notify(s) {
	notifierType = s["type"]
	switch (notifierType) {
		case "MQ":
			log.debug("grab host and other settings for MQ")
			try {
				def today = new Date()
				if (! s.containsKey("port")) {
					s["port"] = 61613
					log.debug("${this.class.name} : default port ${s['port']} for STOMP on MQ host is used")
				}
				agent.stomp_send(s["host"],s["port"],s["username"],s["passcode"], s["queuename"],"demoing: " + today)
			} catch (Exception ex) {
				log.error(this.class.name + ": messaging notification for oid: ${oid} failed.", ex)
			}
			break
		case "emailer":
			log.debug("grab receipients or other info for emailer")
			try {
				agent.sendEmail(emailingConfId, tfp)
			} catch (Exception ex) {
				log.error(this.class.name + ": emailing notification for oid: ${oid} filed.", ex)
			}
			break
		default:
			log.error("Wrong notifier type")
	}
}