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
```
/var/log/hive/metrics.json
```
This file is then uploaded to S3, where the Json Exporter scrapes the metrics and stores them in Prometheus. 
The S3 file is deleted at the start and end of every run to prevent stale metrics being scraped. 

# Upgrading to EMR 6.2.0

There is a requirement for our data products to start using Hive 3 instead of Hive 2. Hive 3 comes bundled with EMR 6.2.0 
along with other upgrades including Spark. Below is a list of steps taken to upgrade PDM to EMR 6.2.0  

1. Make sure you are using an AL2 ami 

2. Point PDM at the new metastore: `hive_metastore_v2` in `internal-compute` instead of the old one in the configurations.yml   

    The values below should resolve to the new metastore, the details of which are an output of `internal-compute`
    ```    
   "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_endpoint}:3306/${hive_metastore_database_name}?createDatabaseIfNotExist=true"
   "javax.jdo.option.ConnectionUserName": "${hive_metsatore_username}"
   "javax.jdo.option.ConnectionPassword": "${hive_metastore_pwd}"
   ```

3. Create ingress/egress security group rules to the metastore in the `internal-compute` repo. Example below   

    ```
    resource "aws_security_group_rule" "ingress_pdm" {
      description              = "Allow mysql traffic to Aurora RDS from PDM"
      from_port                = 3306
      protocol                 = "tcp"
      security_group_id        = aws_security_group.hive_metastore_v2.id
      to_port                  = 3306
      type                     = "ingress"
      source_security_group_id = data.terraform_remote_state.pdm.outputs.pdm_common_sg.id
    }
    
    resource "aws_security_group_rule" "egress_pdm" {
      description              = "Allow mysql traffic to Aurora RDS from PDM"
      from_port                = 3306
      protocol                 = "tcp"
      security_group_id        = data.terraform_remote_state.pdm.outputs.pdm_common_sg.id
      to_port                  = 3306
      type                     = "egress"
      source_security_group_id = aws_security_group.hive_metastore_v2.id
    }
    ```

3. Rotate the `pdm-writer` user from the `internal-compute` pipeline so that when PDM starts up it can login to the metastore.

4. Give IAM permissions to the PDM EMR launcher to read the new Secret  

    ```
    data "aws_iam_policy_document" "pdm_emr_launcher_getsecrets" {
     statement {
       effect = "Allow"
    
       actions = [
         "secretsmanager:GetSecretValue",
       ]
    
       resources = [
         data.terraform_remote_state.internal_compute.outputs.metadata_store_users.pdm_writer.secret_arn,
       ]
     }
    }
    ``` 
   
5. Bump the EMR version to 6.2.0 and launch the cluster.   

6. TODO: still figuring out how to get the speed back to normal. Once done update this with instructions

Make sure that the first time anything uses the metastore it initialises with Hive 3, otherwise it will have to be rebuilt. 
