---
BootstrapActions:
- Name: "get-dks-cert"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/emr-setup.sh"
- Name: "installer"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/installer.sh"
Steps:
- Name: "source"
  HadoopJarStep:
    Args:
    - "hive"
    - "-f"
    - "/opt/emr/source.sql"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "transform"
  HadoopJarStep:
    Args:
    - "hive"
    - "-f"
    - "/opt/emr/transform.sql"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "model"
  HadoopJarStep:
    Args:
    - "hive"
    - "-f"
    - "/opt/emr/model.sql"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"

