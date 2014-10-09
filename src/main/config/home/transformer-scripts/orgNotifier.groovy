import com.googlecode.fascinator.transformer.ScriptingTransformer
import com.googlecode.fascinator.common.FascinatorHome;
import com.googlecode.fascinator.common.JsonSimple;
import com.googlecode.fascinator.api.storage.StorageException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;



// Send notifications to organisations listed in the contact section: 
//   dataprovider:organization, requester:organization or nodecontact:organization.
conf = ["dataprovider" : [
	"org1":[["type": "MQ", "host":"11.xx.ss.xx","port":61613,"username":"user","passcode":"pass","queuename":"q"]],
	"org2":[["type": "emailer"]],
	"org":[["type": "MQ", "host":"11.xx.ss.xx","port":61613,"username":"user","passcode":"pass","queuename":"q"], ["type": "emailer"]]
	],
"requester": [
	"org1":[["type": "MQ", "host":"11.xx.ss.xx","port":61613,"username":"user","passcode":"pass","queuename":"q"]],
	"org2":[["type": "emailer"]],
	"org":[["type": "MQ", "host":"11.xx.ss.xx","port":61613,"username":"user","passcode":"pass","queuename":"q"], ["type": "emailer"]]
	],
"nodecontact": [
	"org1":[["type": "MQ", "host":"11.xx.ss.xx","port":61613,"username":"user","passcode":"pass","queuename":"q"]],
	"org2":[["type": "emailer"]],
	"org":[["type": "MQ", "host":"11.xx.ss.xx","port":61613,"username":"user","passcode":"pass","queuename":"q"], ["type": "emailer"]]
	]
]
// message queue host settings should like this
//	    "type": "MQ",
//	    "Host": "xxx.xxx.xxx.xxx",
//	    "Username": "arms",
//	    "Passcode": "pass",
//	    "QueueName": "name"

log = LoggerFactory.getLogger(ScriptingTransformer.class)

log.debug(conf.toString())

emailingConfId = "MetafeedNotifier"

oid = digitalObject.getId()
tfp = getTfPackage()
dataprovider = tfp.getString(null,"dataprovider:organization")
requester = tfp.getString(null,"requester:organization")
nodecontact = tfp.getString(null,"nodecontact:organization")

log.debug("dataprovider:organization = ${dataprovider}")
log.debug("requester:organization = ${requester}")
log.debug("nodecontact:organization = ${nodecontact}")

Class classDef = this.class.classLoader.parseClass(new File(FascinatorHome.getPath("transformer-scripts/") + "/NotificationAgent.groovy"))

agent = classDef.newInstance()
agent.doatest()

for (c in ["dataprovider", "requester", "nodecontact"]) {
	org = tfp.getString(null, c+":organization")
	if (conf[c].containsKey(org)) {
		log.debug("A ${c} notification for ${org} has been configured.")
		notifiers = conf[c][org]
		log.debug(notifiers.toString())
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

void notify(s) {
	notifierType = s["type"]
	switch (notifierType) {
		case "MQ":
			log.debug("grab host and other settings for MQ")
			try {
				agent.stomp_send(s["host"],s["port"],s["username"],s["passcode"], s["queuename"],"testing")
			} catch (Exception ex) {
				log.error("Failed to send messaging notification for oid:" + oid, ex);
			}
			break
		case "emailer":
			log.debug("grab receipients or other info for emailer")
			try {
				agent.sendEmail(emailingConfId, tfp)
			} catch (Exception ex) {
				log.error("Failed to send email notification for oid:" + oid, ex);
			}
			break
		default:
			log.error("Wrong notifier type")
	}
}