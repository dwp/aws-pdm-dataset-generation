# DO NOT USE THIS REPO - MIGRATED TO GITLAB


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

## Concourse pipeline

There is a concourse pipeline for Clive named `pdm-dataset-generation`. The code for this pipeline is in the `ci` folder. The main part of the pipeline (the `master` group) deploys the infrastructure and runs the e2e tests. There are a number of groups for rotating passwords and there are also admin groups for each environment.

### Admin jobs

There are a number of available admin jobs for each environment. These can be found in the [Concourse Utility pipeline](https://ci.dataworks.dwp.gov.uk/teams/utility/pipelines/pdm-emr-admin)

#### Start cluster

This job will start an pdm cluster running. In order to make the cluster do what you want it to do, you can alter the following environment variables in the pipeline config and then run `aviator` to update the pipeline before kicking it off:

1. S3_PREFIX (required) -> the S3 output location for the HTME data to process, i.e. `analytical-dataset/2020-08-13_22-16-58/`
1. EXPORT_DATE (required) -> the date the data was exported, i.e `2021-04-01`
1. CORRELATION_ID (required) -> the correlation id for this run, i.e. `<some_unique_correlation_id>`
1. SNAPSHOT_TYPE (required) -> `full`

#### Stop clusters

For stopping clusters, you can run the `stop-cluster` job to terminate ALL current `pdm` clusters in the environment.

### Clear dynamo row (i.e. for a cluster restart)

Sometimes the pdm cluster is required to restart from the beginning instead of restarting from the failure point.
To be able to do a full cluster restart, delete the associated DynamoDB row if it exists. The keys to the row are `Correlation_Id` and `DataProduct` in the DynamoDB table storing cluster state information (see [Retries](#retries)).   
The `clear-dynamodb-row` job is responsible for carrying out the row deletion.

To do a full cluster restart

* Manually enter CORRELATION_ID and DATA_PRODUCT of the row to delete to the `clear-dynamodb-row` job and run aviator.


    ```
    jobs:
      - name: dev-clear-dynamodb-row
        plan:
          - .: (( inject meta.plan.clear-dynamodb-row ))
            config:
              params:
                AWS_ROLE_ARN: arn:aws:iam::((aws_account.development)):role/ci
                AWS_ACC: ((aws_account.development))
                CORRELATION_ID: <Correlation_Id of the row to delete>
                DATA_PRODUCT: <DataProduct of the row to delete>

    ```
* Run the admin job to `<env>-clear-dynamodb-row`

* You can then run `start-cluster` job with the same `Correlation_Id` from fresh.

### Pipeline not running in QA?

There is an automated AMI upgrade pipeline embedded into the pipeline of this repo (`ci/jobs/ami-test`). This is in a `serial_group` with the QA deployment pipeline to ensure that they do not interfere with each other.

Please let the tests run and the deployment pipeline will continue automatically.

## Full cluster restart

Sometimes the PDM cluster is required to restart from the beginning instead of restarting from the failure point.
To be able to do a full cluster restart, delete the associated DynamoDB row if it exists. The keys to the row are `Correlation_Id` and `DataProduct` in the DynamoDB table storing cluster state information (see [Retries on cluster failure](#retries-on-cluster-failure)). 
The ```clear-dynamodb-row``` job is responsible for carrying out the row deletion.

To do a full cluster restart

* Manually enter CORRELATION_ID and DATA_PRODUCT of the row to delete to the `clear-dynamodb-row` job and run aviator.


    ```
    jobs:
      - name: dev-clear-dynamodb-row
        plan:
          - .: (( inject meta.plan.clear-dynamodb-row ))
            config:
              params:
                AWS_ROLE_ARN: arn:aws:iam::((aws_account.development)):role/ci
                AWS_ACC: ((aws_account.development))
                CORRELATION_ID: <Correlation_Id of the row to delete>
                DATA_PRODUCT: <DataProduct of the row to delete>

    ```
* Run the admin job to `<env>-clear-dynamodb-row`

* You can then run `start-cluster` job with the same `Correlation_Id` from fresh.



## Metrics

This clusters metrics are exported using Json Exporter. The metrics file is created and written locally to 
```
/var/log/hive/metrics.json
```
This file is then uploaded to S3, where the Json Exporter scrapes the metrics and stores them in Prometheus. 
The S3 file is deleted at the start and end of every run to prevent stale metrics being scraped. 

Additional metrics such as pdm_views_table_count, pdm_views_row_count and pdm_views_max_date are sent to the PDM pushgateway.
These metrics represent the number of tables in the PDM database, the total number of row in the PDM database and the time at which the latest raw entry was added.

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



## How the PDM object tagger works

Upon the successful execution of PDM, a `pdm_success` Cloudwatch Event is created. When this event is created it
triggers an event rule named `pdm_success_start_object_tagger`.

Definitions for both of these can be found within `cloudwatch_events.tf`.

The Event rule will trigger a batch job titled `s3_object_tagger` with 2 parameters, which are provided as
values on the rule definition using `local.data_classification` which can be found in `local.tf`.

### Parameters

|       Key      |                   Example                    |
|----------------|----------------------------------------------|
| data-s3-prefix | analytical-dataset/full/2021-04-01_09-40-02  |
| csv-location   | s3://bucket/prefix/data.csv                  |
