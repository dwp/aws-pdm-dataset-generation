# aws-pdm-dataset-generation
Repo for PDM dataset generation

## Initial setup:
PDM requires that data from Crown platform (HDFS location) be ingested for 5 tables namely `agent_dim`, `appointment_type_dim`, `site_dim`, `team_dim`, `to_do_type_type_dim`.
This data is ingested into S3 from Crown through a Concourse job and placed into `common-model-inputs/transactional_data` prefix of the `published_bucket`.
When `initial_transactional_load` property in `local.tf` is set to `true` for each environment, the `initial_transactional_load` step in the application will create tables for the initial transactional tables.


## Retries on cluster failure

When the PDM cluster fails or succeeds it creates a cloudwatch event. A cluster can fail for a multitude of reasons, therefore 
an automated retry of a failed cluster is warranted.   

PDM logs its run information into a DynamoDB table with the following structure:  

| Correlation_Id | DataProduct |    Date    | Run_Id | Status | CurrentStep | TimeToExist | Cluster_Id |   S3_Prefix_Snapshots   |   S3_Prefix_Analytical_DataSet   |   Snapshot_Type   |
|----------------|-------------|------------|--------|--------|-------------|-------------|------------|-------------------------|-------------------------------|-------------------|
|      123       |     PDM     | 2021-02-11 |    1   | FAILED |    Model    |             | j-1SM0GDS5 | path_to_snapshot_data/  | path_to_analytical_data/       |        full         | 
    
The cluster will log information resembling the above DynamoDB table. If it fails, it will kick off a cloudwatch event that has a target lambda - [dataworks-emr-relauncher](https://github.com/dwp/dataworks-emr-relauncher)   
The retry logic is contained within that lambda as well as more detailed documentation. If the failed cluster is restarted
it will skip to the failed step and resume from there. 

## Metrics

This clusters metrics are exported using Json Exporter. The metrics file is created and written locally to 
```/var/log/hive/metrics.json
```
This file is then uploaded to S3, where the Json Exporter scrapes the metrics and stores them in Prometheus. 
The S3 file is deleted at the start and end of every run to prevent stale metrics being scraped. 