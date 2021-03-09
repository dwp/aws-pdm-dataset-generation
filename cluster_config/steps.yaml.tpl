---
BootstrapActions:
- Name: "download-scripts"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/download_scripts.sh"
- Name: "start_ssm"
  ScriptBootstrapAction:
    Path: "file:/var/ci/start_ssm.sh"
- Name: "get-dks-cert"
  ScriptBootstrapAction:
    Path: "file:/var/ci/emr-setup.sh"
- Name: "installer"
  ScriptBootstrapAction:
    Path: "file:/var/ci/installer.sh"
- Name: "download-pdm-sql"
  ScriptBootstrapAction:
    Path: "file:/var/ci/download_sql.sh"
- Name: "application-metrics-setup"
  ScriptBootstrapAction:
    Path: "file:/var/ci/application-metrics-setup.sh"
Steps:
- Name: "courtesy-flush"
  HadoopJarStep:
    Args:
    - "/var/ci/courtesy-flush.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "create-hive-dynamo-table"
  HadoopJarStep:
    Args:
    - "/var/ci/create-hive-dynamo-table.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "metrics-setup"
  HadoopJarStep:
    Args:
    - "/var/ci/metrics-setup.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "clean-dictionary-data"
  HadoopJarStep:
    Args:
    - "/var/ci/clean_dictionary_data.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "create_databases"
  HadoopJarStep:
    Args:
    - "/var/ci/create_databases.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "transactional"
  HadoopJarStep:
    Args:
    - "/var/ci/transactional.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "initial_transactional_load"
  HadoopJarStep:
    Args:
    - "/var/ci/initial_transactional_load.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "source"
  HadoopJarStep:
    Args:
    - "/var/ci/source.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "transform"
  HadoopJarStep:
    Args:
    - "/var/ci/transform.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "model"
  HadoopJarStep:
    Args:
    - "/var/ci/model.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "views"
  HadoopJarStep:
    Args:
    - "/var/ci/views.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "create-views-tables"
  HadoopJarStep:
    Args:
    - "/var/ci/create-views-tables.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "collect-metrics"
  HadoopJarStep:
    Args:
    - "/var/ci/collect-metrics.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "flush-s3"
  HadoopJarStep:
    Args:
    - "/var/ci/flush-s3.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
