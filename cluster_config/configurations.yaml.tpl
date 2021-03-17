---
Configurations:
- Classification: "yarn-site"
  Properties:
    "yarn.log-aggregation-enable": "true"
    "yarn.nodemanager.remote-app-log-dir": "s3://${s3_log_bucket}/${s3_log_prefix}/yarn"
- Classification: "hive-site"
  Properties:
    "hive.metastore.schema.verification": "false"
    "hive.metastore.warehouse.dir": "s3://${s3_published_bucket}/${hive_metastore_location}"
    "hive.metastore.metrics.enabled": "true"
    "hive.server2.metrics.enabled": "true"
    "hive.service.metrics.reporter": "JSON_FILE"
    "hive.service.metrics.file.location": "/var/log/hive/metrics.json"
    "hive.txn.manager": "org.apache.hadoop.hive.ql.lockmgr.DbTxnManager"
    "hive.exec.dynamic.partition.mode": "nostrict"
    "hive.compactor.initiator.on": "true"
    "hive.compactor.worker.threads": "${hive_compaction_threads}"
    "hive.support.concurrency": "true"
    "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_endpoint}:3306/${hive_metastore_database_name}?createDatabaseIfNotExist=true"
    "javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver"
    "javax.jdo.option.ConnectionUserName": ${hive_metastore_username}
    "javax.jdo.option.ConnectionPassword": ${hive_metastore_pwd}
    "hive.mapred.mode": "nonstrict"
    "hive.strict.checks.cartesian.product": "false"
    "hive.exec.parallel": "true"
    "hive.exec.failure.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.exec.post.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.exec.pre.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.vectorized.execution.enabled": "false"
    "hive.vectorized.execution.reduce.enabled": "false"
    "hive.vectorized.complex.types.enabled": "false"
    "hive.vectorized.use.row.serde.deserialize": "false"
    "hive.vectorized.execution.ptf.enabled": "false"
    "hive.vectorized.row.serde.inputformat.excludes": ""
    "hive_timeline_logging_enabled": "true"
    "hive.server2.tez.sessions.per.default.queue": "5"
    "hive.server2.tez.initialize.default.sessions": "true"
- Classification: "tez-site"
  Properties:
    "tez.am.resource.memory.mb": "1024"
    "tez.am.container.reuse.enabled": "true"
- Classification: "emrfs-site"
  Properties:
    "fs.s3.maxConnections": "10000"
    "fs.s3.maxRetries": "20"
- Classification: "hadoop-env"
  Configurations:
  - Classification: "export"
    Properties:
      "HADOOP_NAMENODE_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7101:/opt/emr/metrics/prometheus_config.yml\""
      "HADOOP_DATANODE_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7103:/opt/emr/metrics/prometheus_config.yml\""
- Classification: "yarn-env"
  Configurations:
  - Classification: "export"
    Properties:
      "YARN_RESOURCEMANAGER_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7105:/opt/emr/metrics/prometheus_config.yml\""
      "YARN_NODEMANAGER_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7107:/opt/emr/metrics/prometheus_config.yml\""
