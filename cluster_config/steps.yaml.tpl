---
BootstrapActions:
- Name: "start_ssm"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/start_ssm.sh"
- Name: "get-dks-cert"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/emr-setup.sh"
- Name: "installer"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/installer.sh"
- Name: "download-pdm-sql"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/download_sql.sh"
- Name: "application-metrics-setup"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/application-metrics-setup.sh"
Steps:
- Name: "create-hive-dynamo-table"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/create-hive-dynamo-table.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "metrics-setup"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/metrics/metrics-setup.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "clean-dictionary-data"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/clean_dictionary_data.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "create-databases"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/create_db.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "intial_transactional_load"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/intial_transactional_load.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "transactional"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/transactional.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "source"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/source.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "transform"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/transform.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "model"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/model.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "views"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/views.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "create-views-tables"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/create-views-tables.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "row-count"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/row-count.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "collect-metrics"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/collect-metrics.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
