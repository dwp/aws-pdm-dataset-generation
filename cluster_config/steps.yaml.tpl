---
BootstrapActions:
- Name: "get-dks-cert"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/emr-setup.sh"
- Name: "installer"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/installer.sh"
- Name: "download-pdm-sql"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/download_sql.sh"
Steps:
- Name: "metrics-setup"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/metrics/metrics-setup.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "addresses-tagged"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/addresses_tagged.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "transactional"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/transactional.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "source"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/source.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "transform"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/transform.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "model"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/model.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "views"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/views.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"

