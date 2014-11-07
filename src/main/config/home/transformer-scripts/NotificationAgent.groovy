import org.slf4j.Logger
import org.slf4j.LoggerFactory

import com.googlecode.fascinator.common.FascinatorHome
import com.googlecode.fascinator.transformer.ScriptingTransformer
import org.apache.activemq.transport.stomp.StompConnection

class NotificationAgent {
	def log = LoggerFactory.getLogger(ScriptingTransformer.class)
	def host, port, username, passcode
 
	public NotificationAgent() {		
		log.debug("Class " + this.class.name + " has been loaded")
	}
	
	// sends message to:
	// 1. Exchange 	(AMQP default)
	// 2. Routing Key: queueName
	void stomp_send(String h, Integer p, String u, String pass, String queueName, String message) {
		host = h
		port = p
		username = u
		passcode = pass
		StompConnection oConnection = new StompConnection();
		log.debug(this.class.name + ": host = ${host}:${port} with ${username}:${passcode}.");
		oConnection.open(host, port);
		oConnection.connect(username, passcode);
		
		log.debug(this.class.name + " sending: ${message}")
		oConnection.send("/queue/" + queueName, message, null, null);
		log.debug(this.class.name + ": message sending completed.");
		
		oConnection.disconnect();
	}
	
	void sendEmail(emailingConfId, tfp, addressess=null) {
		Class emailerClass = new GroovyClassLoader(getClass().getClassLoader()).parseClass(new File(FascinatorHome.getPath("process/") + "/emailer.groovy"))
		def emailer = emailerClass.newInstance()
		def oid = tfp.getString(null, "oid")
		emailer.sendNotification(emailingConfId, tfp, addressess)
	}
}