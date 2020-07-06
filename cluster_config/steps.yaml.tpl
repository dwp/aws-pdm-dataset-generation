---
BootstrapActions:
- Name: "get-dks-cert"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/emr-setup.sh"
- Name: "installer"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/installer.sh"
Steps:
- Name: "hive-setup"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/hive-setup.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "submit-job"
  HadoopJarStep:
    Args:
    - "spark-submit"
    - "/opt/emr/generate_pdm_dataset.py"
    - "--deploy-mode"
    - "cluster"
    - "--master"
    - "yarn"
    - "--conf"
    - "spark.yarn.submit.waitAppCompletion=true"
    Jar: "command-runner.jar"
  ActionOnFailure: "CONTINUE"

