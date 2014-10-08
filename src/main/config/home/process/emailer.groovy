import groovy.json.*
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.googlecode.fascinator.transformer.ScriptingTransformer
import com.googlecode.fascinator.common.JsonObject
import org.json.simple.JSONArray;
import org.apache.velocity.VelocityContext;
import com.googlecode.fascinator.common.JsonSimple;
import com.googlecode.fascinator.common.FascinatorHome;
import com.googlecode.fascinator.spring.ApplicationContextProvider
import org.apache.commons.mail.SimpleEmail
import org.apache.commons.mail.Email
import org.apache.commons.mail.DefaultAuthenticator

class Emailer {
	def log = LoggerFactory.getLogger(ScriptingTransformer.class)

	public void sendNotification(String setId, String oid, JsonSimple tfPackage) {
		log.debug("Emailer sending: '${setId}' for ${oid}")
		String configPath = FascinatorHome.getPath("process") + "/email-notification-config.json"
		def stages = ["pre", "main", "post"]
		def configJson = new JsonSimple(new File(configPath))
		def dataMap = ["indexer":ApplicationContextProvider.getApplicationContext().getBean("fascinatorIndexer")]

		for (Object procObj : configJson.getJsonArray()) {
			JsonSimple pconfig = new JsonSimple((JsonObject) procObj);
			String procId = pconfig.getString("", "id");
			HashMap<String, Object> procDataMap = new HashMap<String, Object>();
			procDataMap.put("indexer", dataMap.get("indexer"));
			if (procId == setId) {
				stages.each {stage->
					for (Object stageObj : pconfig.getArray(stage)) {
						JsonSimple procJson = new JsonSimple((JsonObject) stageObj);
						String procClassName = procJson.getString("", "class");
						String procConfigPath = procJson.getString("", "config");
						String procInputKey = procJson.getString("", "inputKey");
						String procOutputKey = procJson.getString("", "outputKey");
						def procClass = Class.forName(procClassName)
						def procInst = procClass.newInstance()
						if (stage == "main") {
							dataMap[procInputKey] << oid
							def failedOids = []
							JsonSimple config = new JsonSimple(new File(procConfigPath))
							procInst.init(config)
							JSONArray emailConfigBlocks = config.getArray(setId);
							def emailConfigs = []
							if (emailConfigBlocks != null) {
								for (Object configBlockObj : emailConfigBlocks) {
									JsonSimple emailConfig = new JsonSimple(
											(JsonObject) configBlockObj);
									emailConfigs << emailConfig
								}
							} else {
								emailConfigs << config
							}

							emailConfigs.each {emailConfig->
								// initialize the velocity context
								String subjectTemplate = emailConfig.getString("", "subject");
								String bodyTemplate = emailConfig.getString("", "body");
								List<String> vars = emailConfig.getStringList("vars");

								log.debug("Email step with subject template: " + subjectTemplate);

								//	Replaces any variables in the templates using the mapping specified in the config.
								VelocityContext context = new VelocityContext();
								for (String var : vars) {
									String varField = emailConfig.getString("", "mapping", var);
									String replacement = tfPackage.getString(null, varField)
									if (replacement == null) { // allow empty string as a valid value
										JSONArray arr = tfPackage.getArray(varField)
										if (arr != null && arr.size() > 0) {
											replacement = (String) arr.get(0)
											if (replacement == null) {
												// Invalid value in the package, setting back to source value so caller can evaluate
												log.warn("Replacement of ${var} (field '${varField}') found null in the package, variable name is not mapped." )
												replacement = var;
											}
										} else {
											// giving up, setting back to source value so caller can evaluate
											log.warn("Replacement of ${var} (field '${varField}' in the package) was not found, variable name ${var} is not mapped.")
											replacement = var
										}
									} else {
										log.debug("Mapping var '${var}' by looking for field '${varField}' in the package. The value is: ${replacement}")
									}
									context.put(var.replace("\$", ""), replacement)
								}
								
								String subject = procInst.evaluateStr(subjectTemplate, context);
								String body = procInst.evaluateStr(bodyTemplate, context);
								String to = emailConfig.getString("", "to");
								String from = emailConfig.getString("", "from");
								String cc = procInst.evaluateStr(emailConfig.getString("", "cc"), context)
								String recipient = procInst.evaluateStr(to, context);
								if (recipient.startsWith("\$")) {
									// exception encountered...
									log.error("Failed to build the email recipient:'"
											+ recipient
											+ "'. Please check the mapping field and verify that it exists and is populated in Solr.");
									failedOids.add(oid);
								} else {
									procInst.metaClass.emailWithCc = emailWithCc;
									// send email
									log.debug("Sending email for oid: ${oid}")
									if (!procInst.emailWithCc(oid, from, recipient, subject, body, cc)) {
										failedOids.add(oid);
									}
								}
							}
							dataMap[procOutputKey] = failedOids
						} else {
							procInst.process(setId, procInputKey, procOutputKey, stage, procConfigPath, dataMap)
						}
					}
				}
			}
		}
	}

	def emailWithCc = {oid, from, recipient, subject, body, cc->
		try {
			Email email = new SimpleEmail();
			log.debug("Email host: " + host);
			log.debug("Email port: " + port);
			log.debug("Email username: " + username);
			log.debug("Email from: " + from);
			log.debug("Email to: " + recipient);
			log.debug("Email cc: " + cc);
			log.debug("Email Subject is: " + subject);
			log.debug("Email Body is: " + body);
			email.setHostName(host);
			email.setSmtpPort(Integer.parseInt(port));
			email.setAuthenticator(new DefaultAuthenticator(username, password));
			// the method setSSL is deprecated on the newer versions of commons
			// email...
			email.setSSL("true".equalsIgnoreCase(ssl));
			email.setTLS("true".equalsIgnoreCase(tls));
			email.setFrom(from);
			email.setSubject(subject);
			email.setMsg(body);

			if (recipient.indexOf(",") >= 0) {
				String[] recs = recipient.split(",");
				for (String rec : recs) {
					email.addTo(rec);
				}
			} else {
				email.addTo(recipient);
			}
			if (cc.indexOf(",") >= 0) {
				String[] recs = cc.split(",");
				for (String rec : recs) {
					email.addCc(rec);
				}
			} else {
				if (cc != "") {
					email.addCc(cc);
				}
			}
			email.send();
		} catch (Exception ex) {
			log.error("Failed to send notification for oid:" + oid, ex);
			return false;
		}
		return true;
	}
}
