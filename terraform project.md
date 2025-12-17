terraform project

- i have several AWS accounts,using cloudwatch to monitor the metrics and set alarms
- i want to create a terraform project to monitor the metrics and set alarms

- targets:  
    - several EC2
    - several RDS
    - several S3
    - several ALB
    - several API Gateway
    - several Lambda

- metrics: 
    - for most of the instances, i want monitor common metrics like CPU, memory, IO, disk
    - but some may need special metrics, base on the use case

- alarms: 
    - simply just sns topics
    - but leave enough space for expansion

- request:
    - since the large number of targets, i want a DRY way to create the alarms, using template or module
    - for those need special treatment, i want to be able to override the default settings
    
- task: 
    - a complete terraform project structure
    - a detailed walkthrough