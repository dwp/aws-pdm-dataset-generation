---
Configurations:
- Classification: "yarn-site"
  Properties:
    "yarn.log-aggregation-enable": "true"
    "yarn.nodemanager.remote-app-log-dir": "s3://${s3_log_bucket}/${s3_log_prefix}/yarn"
- Classification: "hive-site"
  Properties:
    "hive.metastore.schema.verification": "false"
    "hive.metastore.warehouse.dir": "s3://${s3_published_bucket}/pdm-dataset/hive/external"
    "hive.metastore.metrics.enabled": "true"
    "hive.server2.metrics.enabled": "true"
    "hive.service.metrics.reporter": "JSON_FILE"
    "hive.service.metrics.file.location": "/var/log/hive/metrics.json"
    "hive.txn.manager": "org.apache.hadoop.hive.ql.lockmgr.DbTxnManager"
    "hive.enforce.bucketing": "true"
    "hive.exec.dynamic.partition.mode": "nostrict"
    "hive.compactor.initiator.on": "true"
    "hive.compactor.worker.threads": "1"
    "hive.support.concurrency": "true"
    "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_endpoint}:3306/${hive_metastore_database_name}?createDatabaseIfNotExist=true"
    "javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver"
    "javax.jdo.option.ConnectionUserName": ${hive_metsatore_username}
    "javax.jdo.option.ConnectionPassword": ${hive_metastore_pwd}
    "hive.mapred.mode": "nonstrict"
    "hive.strict.checks.cartesian.product": "false"
- Classification: "emrfs-site"
  Properties:
    "fs.s3.consistent": "true"
    "fs.s3.consistent.metadata.read.capacity": "800"
    "fs.s3.consistent.metadata.write.capacity": "200"
    "fs.s3.maxConnections": "10000"
    "fs.s3.consistent.retryPolicyType": "fixed"
    "fs.s3.consistent.retryPeriodSeconds": "2"
    "fs.s3.consistent.retryCount": "10"
    "fs.s3.consistent.metadata.tableName": "${emrfs_metadata_tablename}"
