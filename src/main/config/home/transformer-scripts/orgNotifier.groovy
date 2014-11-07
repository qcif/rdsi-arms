import com.googlecode.fascinator.transformer.ScriptingTransformer
import com.googlecode.fascinator.common.FascinatorHome
import com.googlecode.fascinator.common.JsonSimple
import groovy.json.JsonSlurper

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

emailingConfId = "MetafeedNotifier"
NotificationState="arms-provisioned"
IndicationField = "metadatafeed-notification"
def contactType = "dataprovider"

// Send notifications to organisations listed in the contact section:
// one type only, currently: dataprovider:organization

log = LoggerFactory.getLogger(ScriptingTransformer.class)

def confJson = new JsonSlurper().parse(new File(FascinatorHome.getPath("organisation-provisioning.json")))
//log.debug(confJson.getClass().toString())
conf = [(contactType):confJson]
//log.debug(conf.toMapString())

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
					notify(notifiers)
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
	notifierType = s["method"]
	settings = s["properties"]
	switch (notifierType) {
		case "stomp":
			log.debug("grab host and other settings for MQ")
			try {
				def today = new Date()
				if (! settings.containsKey("port")) {
					settings["port"] = 61613
					log.debug("${this.class.name} : default port ${s['port']} for STOMP on MQ host is used")
				}
				agent.stomp_send(settings["host"],settings["port"],settings["username"],settings["passcode"], settings["queuename"],"demoing: " + today)
			} catch (Exception ex) {
				log.error(this.class.name + ": messaging notification for oid: ${oid} failed.", ex)
			}
			break
		case "email":
			log.debug("grab receipients or other info for emailer")
			try {
				agent.sendEmail(emailingConfId, tfp, settings["emailAddress"])
			} catch (Exception ex) {
				log.error(this.class.name + ": emailing notification for oid: ${oid} filed.", ex)
			}
			break
		default:
			log.error("Wrong notifier type")
	}
}
