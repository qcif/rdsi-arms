import com.googlecode.fascinator.transformer.ScriptingTransformer
import com.googlecode.fascinator.common.FascinatorHome;
import com.googlecode.fascinator.common.JsonSimple;
import com.googlecode.fascinator.api.storage.StorageException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.apache.activemq.transport.stomp.StompConnection;

// Send notifications to organisations listed in the contact section: 
//   dataprovider:organization, requester:organization or nodecontact:organization.
conf = ["dataprovider" : [
	"org1":[["type": "MQ", "host":"11.xx.ss.xx"]], 
	"org2":[["type": "emailer", "recipient":"some@org2"]], 
	"org":[["type": "MQ", "host":"11.xx.ss.xx"], ["type": "emailer", "recipient":"some@org2"]]
	],
"requester": [
	"org1":[["type": "MQ", "host":"11.xx.ss.xx"]],
	"org2":[["type": "emailer", "recipient":"some@org2"]],
	"org":[["type": "MQ", "host":"11.xx.ss.xx"], ["type": "emailer", "recipient":"some@org2"]]
	],
"nodecontact": [
	"org1":[["type": "MQ", "host":"11.xx.ss.xx"]],
	"org2":[["type": "emailer", "recipient":"some@org2"]],
	"org":[["type": "MQ", "host":"11.xx.ss.xx"], ["type": "emailer", "recipient":"some@org2"]]
	]
]
// message queue host settings should like this
//	    "type": "MQ",
//	    "Host": "xxx.xxx.xxx.xxx",
//	    "Username": "arms",
//	    "Passcode": "pass",
//	    "QueueName": "name"

log = LoggerFactory.getLogger(ScriptingTransformer.class)

log.debug(nodecontactNotifierConf.toString())

def tfp = getTfPackage()
dataprovider = tfp.getString(null,"dataprovider:organization")
requester = tfp.getString(null,"requester:organization")
nodecontact = tfp.getString(null,"nodecontact:organization")

log.debug("dataprovider:organization = ${dataprovider}")
log.debug("requester:organization = ${requester}")
log.debug("nodecontact:organization = ${nodecontact}")

for (c in ["dataprovider", "requester", "nodecontact"]) {
	org = tfp.getString(null, c+":organization")
	if (conf[c].containsKey(org)) {
		log.debug("A ${c} notification for ${dataprovider} has been configured.")
		notifiers = conf[c][org]
		for (s in notifiers) {
			notify(s)
		}
	} else {
		log.debug("There is no dataproivder type of notification is set for ${dataprovider}.")
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

void notify(s) {
	notifierType = s["type"]
	switch (notifierType) {
		case "MQ":
			log.debug("grab host and other settings for MQ")
			break
		case "emailer":
			log.debug("grab receipient or other info for emailer")
			break
		default:
			log.error("Wrong notifier type")
	}
}