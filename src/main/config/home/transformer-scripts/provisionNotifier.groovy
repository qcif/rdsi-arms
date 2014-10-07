import com.googlecode.fascinator.transformer.ScriptingTransformer
import com.googlecode.fascinator.common.FascinatorHome;
import com.googlecode.fascinator.common.JsonSimple;
import com.googlecode.fascinator.api.storage.StorageException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.apache.activemq.transport.stomp.StompConnection;

// message queue host settings in system-config.json should like this
//	"liveArcProvisioningNotice": {
//	    "id": "scripting",
//	    "scriptType": "groovy",
//	    "scriptPath": "${fascinator.home}/transformer-scripts/provisionNotifier.groovy",
//	    "Host": "xxx.xxx.xxx.xxx",
//	    "Username": "arms",
//	    "Passcode": "pass",
//	    "QueueName": "name"
//	}

host = config.getString(null, "Host")
port = config.getInteger(61613, "Port")
username = config.getString(null, "Username")
passcode = config.getString(null, "Passcode") 
QueueName = config.getString(null, "QueueName")
// Which filed to be set as indication
NotificationState="arms-draft"
IndicationField = "livearc-prov-notification"
emailingId = "LiveArcProvisionNotifier"

log = LoggerFactory.getLogger(ScriptingTransformer.class)
log.debug("host = ${host}")
log.debug("port = ${port}")
log.debug("username = ${username}")
log.debug("passcode = ${passcode}")
log.debug("QueueName = ${QueueName}")

if (host == null || username == null || passcode == null || QueueName == null ) {
	log.error("Message queue error: Host, Username, Passcode and QueueName all has to be set.")
	log.warn("Email notification is skiped because message cannot be sent to the queue.")
	return digitalObject
}
payloads = digitalObject.getPayloadIdList()

if(payloads.contains("workflow.metadata")){
	def workflowMeta = new JsonSimple(digitalObject.getPayload("workflow.metadata").open());
	String workflow = workflowMeta.getString(null,"step")
	if (workflow == NotificationState) {
		log.debug("Current workflow = ${workflow}, so do something.")
		def tfPackageMap = getTfPackage()
		def tfp = tfPackageMap["package"]
		if (! tfp.getBoolean(false, IndicationField)) {
//			stomp_send(QueueName, tfp.toString())
			Class emailerClass = new GroovyClassLoader(getClass().getClassLoader()).parseClass(new File(FascinatorHome.getPath("process/") + "/emailer.groovy"))
			def emailer = emailerClass.newInstance()
			
			String oid = tfp.getString(null, "oid")
			
			tfp.getJsonObject().put(IndicationField, "true")
			saveTfPackage(tfp, tfPackageMap["pid"])
			emailer.sendNotification(emailingId, oid, tfp)
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
			tfPid = pid
		}
	}
	return ["pid":tfPid, "package":tfPackage]
}

def saveTfPackage(tfPackage, pid) {
	try {
		InputStream metaIn = new ByteArrayInputStream(tfPackage.toString(true).getBytes());
		digitalObject.updatePayload(pid, metaIn);
		metaIn.close();
	} catch (IOException ex) {
		throw new StorageException(ex);
	}
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
