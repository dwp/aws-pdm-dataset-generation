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
- Key: "AutoShutdown"
  Value: "False"
- Key: "SSMEnabled"
  Value: "True"
- Key: "Name"
  Value: "aws-pdm-dataset-generator"
- Key: "Application"
  Value: "${application_tag_value}"
- Key: "Function"
  Value: "${function_tag_value}"
- Key: "Business-Project"
  Value: "${business_project_tag_value}"
- Key: "Environment"
  Value: "${environment_tag_value}"
- Key: "DWX_Environment"
  Value: "${dwx_environment_tag_value}"
- Key: "DWX_Application"
  Value: "aws-pdm-dataset-generator"