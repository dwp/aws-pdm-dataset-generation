---
BootstrapActions:
- Name: "get-dks-cert"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/emr-setup.sh"
- Name: "installer"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/installer.sh"
- Name: "download-consolidate-pdm-sql"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/pdm-dataset-generation/download_consolidate_sql.sh"
Steps:
- Name: "metrics-setup"
  HadoopJarStep:
    Args:
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/metrics/metrics-setup.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "source"
  HadoopJarStep:
    Args:
    - "hive"
    - "--hivevar"
    - "source_database=uc_pdm_source"
    - "--hivevar"
    - "serde=org.openx.data.jsonserde.JsonSerDe"
    - "--hivevar"
    - "data_path=s3://${s3_publish_bucket}/analytical-dataset"
    - "-f"
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/source.sql"
    Jar: "command-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "transform"
  HadoopJarStep:
    Args:
    - "hive"
    - "--hivevar" 
    - "source_database=uc_pdm_source"
    - "--hivevar"
    - "transform_database=uc_pdm_transform"
    - "-f"
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/transform.sql"
    Jar: "command-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "model"
  HadoopJarStep:
    Args:
    - "hive"
    - "--hivevar"
    - "model_database=uc_pdm_model"
    - "--hivevar"
    - "transform_database=uc_pdm_transform"
    - "-f"
    - "s3://${s3_config_bucket}/component/pdm-dataset-generation/model.sql"
    Jar: "command-runner.jar"
  ActionOnFailure: "CONTINUE"



