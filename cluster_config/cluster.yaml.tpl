---
Applications:
- Name: "Hive"
CustomAmiId: "${ami_id}"
EbsRootVolumeSize: 100
LogUri: "s3://${s3_log_bucket}/${s3_log_prefix}"
Name: "pdm-dataset-generator"
ReleaseLabel: "emr-${emr_release_label}"
SecurityConfiguration: "${security_configuration}"
ServiceRole: "${service_role}"
JobFlowRole: "${instance_profile}"
VisibleToAllUsers: True
Tags:
- Key: "Persistence"
  Value: "Ignore"
- Key: "Owner"
  Value: "dataworks platform"
- Key: "AutoShutdown"
  Value: "False"
- Key: "CreatedBy"
  Value: "emr-launcher"
- Key: "SSMEnabled"
  Value: "True"
- Key: "Environment"
  Value: "development"
- Key: "Application"
  Value: "aws-pdm-dataset-generator"
- Key: "Name"
  Value: "aws-pdm-dataset-generator"
