Notification
=========

Notifications are managed as a system job defined in system-config.json: 

```javascript
"houseKeeping": {
  "config": {
    "quartzConfig": "${fascinator.home}/quartz.properties",
    "desktop": true,
    "frequency": "3600",
    "jobs": [
      {
        "name": "process-set-all",
        "type": "processingSet",
        "configFile": "${fascinator.home}/process/processConfig.json",
        "setId": "",
        "timing": "0 0/5 * * * ?"
      }
    ]
  }
}
```
The important key is `configFile` which defines what timely processes will be done.

Configure notifications
=========

File `processConfig.json` configures processes:
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
            },
            {   
                "class":"com.googlecode.fascinator.portal.process.HomeInstitutionNotifier",
                "config":"${fascinator.home}/process/notification/homeInstitutions.json",
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
  - `pre`: check if there is anything to process
  - `main`: notify 
  - `post`: update status. if there was any failure, it will be recored here and re-try when next time the process is called. 

Configure a notification
=========

1. define condition in `pre` by setting a query of workflow step in a json file and reference it. For example, for a notification at <strong>arms-approved</strong> step, put below line into <strong>home/process/approvedRecords.json</strong>:

  ```"query": "workflow_step=\"arms-approved\"",```
  
    Then reference it in `config`:  
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
2. define notification in `"main" : []`

    * email notifier:
      ```
    {
      "class": "com.googlecode.fascinator.portal.process.EmailNotifier",
      "config": "${fascinator.home}/process/emailer.json",
      "inputKey": "newOids",
      "outputKey": "failedOids"
    }            
      ```
    
    * institution notifier:
    
    ```
    {
      "class": "com.googlecode.fascinator.portal.process.HomeInstitutionNotifier",
      "config": "${fascinator.home}/process/notification/homeInstitutions.json",
      "inputKey": "newOids",
      "outputKey": "failedOids"
    }               
    ```
      
    You can have one notofier or both.

3. define where to keep status in `post`. In below example, it reuses the condition `config`:

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

### Institution notifier

Institution notifier (`HomeInstitutionNotifier`) is configured for notifying institutions. Institution's notification is configured by two keys: `name` and `channel`.  When a record is being processed, HomeInstitutionNotifier looks for `dataprovider:organization` in a record to find a configured channel.  If it has been found, it uses the configured channel to notify an institution. There are two types of channels are available: email or message queue. The content of notification is <strong>amrs.xml</strong> of the record. With email, a message can also be sent.

For message queue channel, it needs properties set in files of:
 * homeInstNotifier.properties
 * applicationContext-SI_HomeInstNotifier.xml

### Email notifier
Email notifier (`EmailNotifier`) is configure to send emails to peopel. It is configued in `emailer.json`.  The top section are settings for sending out email:

```
    "host":"${smtp.host}",
    "port":"25",
    "username":"${admin.email}",
    "password":"",
    "tls":"true",
    "ssl":"true",
```

After that, there are notifier configuration JSON objects. The name of the JSON object is an `id` in `processConfig.json`. For example, if an `id` is <strong>notifyNewSubmission</strong>, it can be defined as:

```
"notifyNewSubmission": [
  {
    "from": "${admin.email}",
    "to": "$piEmail",
    "subject": "Request submission acknowledgement: '$title'",
    "body": "$fname $lname,\n\nThis email acknowledges your request: '$title'. To view your request, use this link: ${server.url.base}$viewId/detail/$oid \n\nCheers,\nRequest Notifier",
    "vars": [
      "$oid",
      "$title",
      "$fname",
      "$lname",
      "$viewId",
      "$piEmail"
    ],
    "mapping": {
      "$oid": "id",
      "$title": "dc_title",
      "$lname": "requester:familyName",
      "$fname": "requester:givenName",
      "$viewId": "viewId",
      "$piEmail": "requester:email"
    }
  }
]
```

In this example, it defines one email will be sent to the email address given by `requester:email` in the processed record.

Mutilple emails can be configured in the same way. Also the recipient can be a list of email addresses.
