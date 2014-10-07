import com.googlecode.fascinator.transformer.ScriptingTransformer
import com.googlecode.fascinator.common.FascinatorHome;
import com.googlecode.fascinator.common.JsonSimple;
import com.googlecode.fascinator.api.storage.StorageException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.apache.activemq.transport.stomp.StompConnection;

// message queue host settings in system-config.json should like this
// two types are supported: MQ or emailer, it can be either one
//	"liveArcProvisioningNotice": {
//	    "id": "scripting",
//	    "scriptType": "groovy",
//	    "scriptPath": "${fascinator.home}/transformer-scripts/provisionNotifier.groovy",
//	    "type": "MQ",
//	    "Host": "xxx.xxx.xxx.xxx",
//	    "Username": "arms",
//	    "Passcode": "pass",
//	    "QueueName": "name"
//	}


// Which filed to be set as indication
NotificationState="arms-provisioned"
IndicationField = "livearc-prov-notification"
emailingConfId = "LiveArcProvisionNotifier"

log = LoggerFactory.getLogger(ScriptingTransformer.class)

host = null
port = 61613
username = null
passcode = null
QueueName = null

notificationType = config.getString("emailer", "type")
if (notificationType == "MQ") {
	host = config.getString(host, "Host")
	port = config.getInteger(port, "Port")
	username = config.getString(username, "Username")
	passcode = config.getString(passcode, "Passcode")
	QueueName = config.getString(QueueName, "QueueName")
	log.debug("host = ${host}")
	log.debug("port = ${port}")
	log.debug("username = ${username}")
	log.debug("passcode = ${passcode}")
	log.debug("QueueName = ${QueueName}")
	if (host == null || username == null || passcode == null || QueueName == null ) {
		log.error("Message queue error: Host, Username, Passcode and QueueName all has to be set.")
		return digitalObject
	}
}

payloads = digitalObject.getPayloadIdList()
String oid = digitalObject.getId()
def tfp = getTfPackage()

if(payloads.contains("workflow.metadata")){
	def workflowMeta = new JsonSimple(digitalObject.getPayload("workflow.metadata").open());
	String workflow = workflowMeta.getString(null,"step")
	if (workflow == NotificationState) {
		log.debug("Current workflow = ${workflow}, so do something.")
		def objMetadata = digitalObject.getMetadata()
		if (! objMetadata.getProperty(IndicationField)) {
			if (notificationType == "MQ") {
				stomp_send(QueueName, tfp.toString())
			} else {
				Class emailerClass = new GroovyClassLoader(getClass().getClassLoader()).parseClass(new File(FascinatorHome.getPath("process/") + "/emailer.groovy"))
				def emailer = emailerClass.newInstance()
				emailer.sendNotification(emailingConfId, oid, tfp)
			}
			objMetadata.setProperty(IndicationField, "true")
			// Set property in TF-OBJ-META
			ByteArrayOutputStream metaOut = new ByteArrayOutputStream();
			objMetadata.store(metaOut, "");
			InputStream metaIn = new ByteArrayInputStream(metaOut.toByteArray());
			digitalObject.updatePayload("TF-OBJ-META", metaIn);
			metaIn.close();
		} else {
			log.debug("${IndicationField} has been set, skip")
		}
	} else {
		log.debug("Current workflow = ${workflow}, so do nothing.")
	}
}

return digitalObject

// get TFPackage in JSON
def getTfPackage() {
	def tfPackage = null
	def tfPid = ""
	for (pid in digitalObject.getPayloadIdList()) {
		if (pid.endsWith(".tfpackage")){
			def payload = digitalObject.getPayload(pid);
			tfPackage = new JsonSimple(payload.open());
		}
	}
	return tfPackage
}

// sends message to:
// 1. Exchange 	(AMQP default)
// 2. Routing Key: queueName
void stomp_send(String queueName, String message) {
	StompConnection oConnection = new StompConnection();
	log.debug(this.class.name + ": host = ${host}:${port}.");
	oConnection.open(host, port);
	oConnection.connect(username, passcode);
	
	log.debug(this.class.name + ": starting message sending.");
	log.debug(this.class.name + " sending: ${message}")
	oConnection.send("/queue/" + queueName, message, null, null);
	log.debug(this.class.name + ": message sending completed.");
	
	oConnection.disconnect();
}
