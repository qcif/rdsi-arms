##Email notifications

Email notifications can be sent when conditions are met, e.g. a request changes state. The system runs notifications as a scheduled job. The job is configued in a file with conditions and actions. The details of **conditions** and **actions** are defined in different files. The definition of actions including the configuration of connecting STMP server and templates of email.

### Job configuration

Email notifications are managed as a house-kepping job defined in the section of `houseKeeping/config/jobs` in system-config.json. In the example below, it is named as `email-notification`: 

```javascript
"houseKeeping": {
  "config": {
    "quartzConfig": "${fascinator.home}/quartz.properties",
    "desktop": true,
    "frequency": "3600",
    "jobs": [
      {
        "name": "email-notification",
        "type": "processingSet",
        "configFile": "${fascinator.home}/process/email-notification-config.json",
        "setId": "",
        "timing": "0 0/5 * * * ?"
      }
    ]
  }
}
```
####Important fields in configuring the email-notificatin job:
- `name` the name of concerning job
- `configFile` The actual configuration of notifications, e.g. conditions are defined in a file ant its path is defined by `configFile` which defines what timely processes will be done.
- `timing`: Sending frequency. ARMS sends the notification emails at periodic intervals. In the example, notification job will run every 5 minutes. References of `timing` format can be found at [ReDBox site](http://www.redboxresearchdata.com.au/documentation/how-to/scheduling-a-harvest) and [Quartz site](http://www.quartz-scheduler.org/documentation/quartz-1.x/tutorials/crontrigger). 

###Configure notifications

Above mentioned file `email-notification-config.json` configures notification processes -- conditions and actions:
```javascript
[
    {
        "id":"notifyNewSubmission",
        "pre" : [
            {   
                "class":"com.googlecode.fascinator.portal.process.RecordProcessor",
                "config":"${fascinator.home}/process/newRecords.json",
                "inputKey":"",
                "outputKey":"newOids"
            }
        ],
        "main" : [
            {   
                "class":"com.googlecode.fascinator.portal.process.EmailNotifier",
                "config":"${fascinator.home}/process/emailer.json",
                "inputKey":"newOids",
                "outputKey":"failedOids"
            }
        ],
        "post" : [
            {   
                "class":"com.googlecode.fascinator.portal.process.RecordProcessor",
                "config":"${fascinator.home}/process/newRecords.json",
                "inputKey":"failedOids",
                "outputKey":""
            }
        ]
    },
    {
        "id":"notifyApproval",
        "pre" : [
            {   
                "class":"com.googlecode.fascinator.portal.process.RecordProcessor",
                "config":"${fascinator.home}/process/approvedRecords.json",
                "inputKey":"",
                "outputKey":"newOids"
            }
        ],
        "main" : [
            {   
                "class":"com.googlecode.fascinator.portal.process.EmailNotifier",
                "config":"${fascinator.home}/process/emailer.json",
                "inputKey":"newOids",
                "outputKey":"failedOids"
            }            
        ],
        "post" : [
            {   
                "class":"com.googlecode.fascinator.portal.process.RecordProcessor",
                "config":"${fascinator.home}/process/approvedRecords.json",
                "inputKey":"failedOids",
                "outputKey":""
            }
        ]
    }    
]
```
As you can see, each notification is processed in three steps:
  - `pre`: check if there is anything to process
  - `main`: notify 
  - `post`: update status. if there was any failure, it will be recored here and re-try when next time the process is called. 

###Steps of configuring a notification
1. define condition in `"pre": []` by setting a query of workflow step in a json file and reference it. For example, for a notification at <strong>arms-approved</strong> step, put the line below into <strong>home/process/approvedRecords.json</strong>:

  ```"query": "workflow_step=\"arms-approved\"",```
  
    Then reference it in `email-notification-config.json`:  
     ```
    "pre" : [  
      {
        "class": "com.googlecode.fascinator.portal.process.RecordProcessor",
        "config": "${fascinator.home}/process/approvedRecords.json",
        "inputKey": "",
        "outputKey": "newOids"
      }
    ]  
    ```
2. define notifiers in `"main" : []`

    * email notifier:
      ```
    {
      "class": "com.googlecode.fascinator.portal.process.EmailNotifier",
      "config": "${fascinator.home}/process/emailer.json",
      "inputKey": "newOids",
      "outputKey": "failedOids"
    }            
      ```
3. define where to keep status in `"post": []`. In the below example, it reuses the `pre` condition:

    ```
    "post": [
      {
        "class": "com.googlecode.fascinator.portal.process.RecordProcessor",
        "config": "${fascinator.home}/process/approvedRecords.json",
        "inputKey": "failedOids",
        "outputKey": ""
      }
    ]
    ```

##Notifiers
Email notifier (`EmailNotifier`) is configured to send emails and is configured in `emailer.json`.  It has two sections and the top section contains the settings for sending out email using an SMTP server:

```
    "host":"${smtp.host}",
    "port":"25",
    "username":"${admin.email}",
    "password":"",
    "tls":"true",
    "ssl":"true",
```

The fields are:
- host: SMTP server address
- port: SMTP server port number (usually port 25)
- username: identity to use for SMTP server
- password: authentication to use for SMTP server
- tls: secure SMTP
- ssl: secure SMTP
 
###Email templates
After that, there are actual notifier configuration JSON objects. The name of the JSON object is an `id` in `email-notification-config.json`. For example, if an `id` is <strong>notifyNewSubmission</strong>, it can be defined as:

```
"notifyNewSubmission": [
    {
      "from": "${admin.email}",
      "to": "reviewer.email",
      "subject": "[ARMS] Request to review: '$title'",
      "body": "Reviewer,\n\nPlease review the following RDSI allocation request: '$title'.\n\nThis request can be accessed from your ARMS dashboard at ${server.url.base}$viewId/home or directly at: ${server.url.base}$viewId/detail/$oid\n\n--\nARMS",
      "vars": [
        "$oid",
        "$title",
        "$viewId"
      ],
      "mapping": {
        "$oid": "id",
        "$title": "dc_title",
        "$viewId": "viewId"
      }
    }
]
```

In this example, it defines one email will be sent to the email address given by `requester:email` in the processed record. Information from request can be referenced by `mapping` them to variables and used in the email Velocity template.

Recipients can be a list of email addresses. Mutilple emails can be configured in the same way for a notifier. 

###*Reminder*
Configure all correctly. Otherwise, `main.log` will be filled with error messages very quickly if the frequency is high. 
