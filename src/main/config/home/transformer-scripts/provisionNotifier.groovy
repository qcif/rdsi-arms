import com.googlecode.fascinator.common.FascinatorHome
import com.googlecode.fascinator.common.JsonSimple
import com.googlecode.fascinator.transformer.ScriptingTransformer
import org.slf4j.LoggerFactory

// message queue host settings in system-config.json should like this
// two types are supported: MQ or emailer, it can be either one
//	"liveArcProvisioningNotice": {
//	    "id": "scripting",
//	    "scriptType": "groovy",
//	    "scriptPath": "${fascinator.home}/transformer-scripts/provisionNotifier.groovy",
//	    "Type": "MQ",
//	    "Host": "xxx.xxx.xxx.xxx",
//	    "Username": "arms",
//	    "Passcode": "pass",
//	    "QueueName": "name"
//	}

tfKey = "provisioning_checklist.4"
notificationState = "provisioned"
indicationField = "livearc-prov-notification"
emailingConfId = "LiveArcProvisionNotifier"

log = LoggerFactory.getLogger(ScriptingTransformer.class)

JsonSimple tfp = getTfPackage()
tfKeyValue = tfp.getString(null, tfKey)

if (tfKeyValue == notificationState) {
    log.debug(this.class.name + ": A transformer is set for - ${tfKey}, actions may be taken.")
    def objMetadata = digitalObject.getMetadata()
    if (!objMetadata.getProperty(indicationField)) {

        Class classDef = this.class.classLoader.parseClass(new File(FascinatorHome.getPath("transformer-scripts/") + "/NotificationAgent.groovy"))
        agent = classDef.newInstance()

        def notificationType = config.getString("emailer", "Type")
        log.debug("notificationType = ${notificationType}")
        if (notificationType == "MQ") {
            def host = config.getString(null, "Host")
            def port = config.getInteger(61613, "Port")
            def username = config.getString(null, "Username")
            def passcode = config.getString(null, "Passcode")
            def queuename = config.getString(null, "QueueName")
            log.debug("host = ${host}")
            log.debug("port = ${port}")
            log.debug("username = ${username}")
            log.debug("passcode = ${passcode}")
            log.debug("queuename = ${queuename}")
            if (host == null || username == null || passcode == null || queuename == null) {
                log.error("Message queue error: Host, Username, Passcode and QueueName all has to be set.")
            } else {
                agent.stomp_send(host, port, username, passcode, queuename, tfp.toString())
                UpdateIndicationField(objMetadata)
            }
        } else {
            agent.sendEmail(emailingConfId, tfp)
            // TOTO: agent may fail but it is catched, we do not know here, update may be wrong
            UpdateIndicationField(objMetadata)
        }
    } else {
        log.debug("${indicationField} has been set, skip")
    }
} else {
    log.debug(this.class.name + ": No transfomer is set for - ${tfKey}, so do nothing.")
}


return digitalObject

// get TFPackage in JSON
def getTfPackage() {
    def tfPackage = null
    def tfPid = ""
    for (pid in digitalObject.getPayloadIdList()) {
        if (pid.endsWith(".tfpackage")) {
            def payload = digitalObject.getPayload(pid);
            tfPackage = new JsonSimple(payload.open());
        }
    }
    return tfPackage
}

// Set property in TF-OBJ-META
void UpdateIndicationField(objMetadata) {
    objMetadata.setProperty(indicationField, "true")
    ByteArrayOutputStream metaOut = new ByteArrayOutputStream()
    objMetadata.store(metaOut, "")
    InputStream metaIn = new ByteArrayInputStream(metaOut.toByteArray())
    digitalObject.updatePayload("TF-OBJ-META", metaIn)
    metaIn.close()
}