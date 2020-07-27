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
- Name: "source"
  HadoopJarStep:
    Args:
    - "hive"
    - "-f"
    - "/opt/emr/sql/extracted/source/source.sql"
    - "hivevar source_database=uc_pdm_source"
    - "hivevar serde=org.openx.data.jsonserde.JsonSerDe"
    - "hivevar data_path=s3://${s3_publish_bucket}/analytical-dataset"
    Jar: "command-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "transform"
  HadoopJarStep:
    Args:
    - "hive"
    - "-f"
    - "/opt/emr/sql/extracted/transform/transform.sql"
    - "hivevar source_database=uc_pdm_source"
    - "hivevar transform_database=uc_pdm_transform"
    Jar: "command-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "model"
  HadoopJarStep:
    Args:
    - "hive"
    - "-f"
    - "/opt/emr/sql/extracted/model/model.sql"
    - "hivevar model_database=uc_pdm_model"
    - "hivevar transform_database=uc_pdm_transform"
    Jar: "command-runner.jar"
  ActionOnFailure: "CONTINUE"

