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
    - "/opt/emr/sql/source/source.sql"
    Jar: "command-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "transform"
  HadoopJarStep:
    Args:
    - "hive"
    - "-f"
    - "/opt/emr/sql/transform/transform.sql"
    Jar: "command-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "model"
  HadoopJarStep:
    Args:
    - "hive"
    - "-f"
    - "/opt/emr/sql/model/model.sql"
    Jar: "command-runner.jar"
  ActionOnFailure: "CONTINUE"

