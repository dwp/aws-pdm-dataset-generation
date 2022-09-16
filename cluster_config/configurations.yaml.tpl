---
Configurations:
- Classification: "yarn-site"
  Properties:
    "yarn.log-aggregation-enable": "true"
    "yarn.nodemanager.remote-app-log-dir": "s3://${s3_log_bucket}/${s3_log_prefix}/yarn"
    "yarn.nodemanager.vmem-check-enabled": "false"
    "yarn.nodemanager.pmem-check-enabled": "false"

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
    "hive.server2.tez.sessions.per.default.queue": "${hive_tez_sessions_per_queue}"
    "hive.server2.tez.initialize.default.sessions": "true"
    "hive.default.fileformat": "TextFile"
    "hive.default.fileformat.managed": "ORC"
    "hive.exec.orc.split.strategy": "HYBRID"
    "hive.merge.orcfile.stripe.level": "true"
    "hive.orc.compute.splits.num.threads": "10"
    "hive.orc.splits.include.file.footer": "true"
    "hive.compactor.abortedtxn.threshold": "1000"
    "hive.compactor.check.interval": "300"
    "hive.compactor.delta.num.threshold": "10"
    "hive.compactor.delta.pct.threshold": "0.1f"
    "hive.compactor.worker.timeout": "86400"
    "hive.blobstore.optimizations.enabled": "${hive_blobstore_opts_enabled}"
    "hive.blobstore.use.blobstore.as.scratchdir": "${hive_blobstore_as_scratchdir}"
    "hive.server2.tez.session.lifetime": "0"
    "hive.exec.reducers.max": "${hive_max_reducers}"
    "hive.convert.join.bucket.mapjoin.tez": "false"
    "hive.emr.use.hdfs.as.scratch.dir": "true"
    "hive.exec.orc.compression.strategy": "SPEED"
    "hive.mv.files.thread": "40"
    "hive.exec.input.listing.max.threads": "50"
    "fs.s3a.threads.core": "1000"
    "fs.s3a.connection.maximum": "1500"
    "fs.s3a.threads.max": "1000"
    "fs.s3a.max.total.tasks": "1000"
    "hive.auto.convert.join": "true"
    "hive.exec.orc.default.compress": "ZLIB"
    "hive.exec.orc.default.block.size": "268435456"
    "hive.exec.orc.encoding.strategy": "SPEED"
    "hive.exec.orc.default.row.index.stride": "10000"
    "hive.exec.orc.default.stripe.size": "268435456"
    "hive.tez.container.size": "${hive_tez_container_size}"
    "hive.tez.java.opts": "${hive_tez_java_opts}"

- Classification: "tez-site"
  Properties:
    "tez.am.resource.memory.mb": "${tez_am_resource_memory_mb}"
    "tez.am.container.reuse.enabled": "true"
    "tez.grouping.min-size": "${tez_grouping_min_size}"
    "tez.grouping.max-size": "${tez_grouping_max_size}"
<<<<<<< HEAD
=======
    "tez.am.launch.cmd-opts": "${tez_am_launch_cmd_opts}"
    "tez.am.container.reuse.enabled": "true"
>>>>>>> 318a3a4 (config changes)
    "tez.runtime.io.sort": "${tez_runtime_io_sort}"
    "tez.runtime.unordered.output.buffer.size-mb": "${tez_runtime_unordered_output_buffer_size_mb}"

- Classification: "mapred-site"
  Properties:
    "yarn.app.mapreduce.am.resource.mb": "${yarn_mapreduce_am_resourcemb}"

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
