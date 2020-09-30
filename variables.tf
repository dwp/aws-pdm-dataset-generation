variable "emr_release" {
  description = "Version of AWS EMR to deploy with associated applications"
  default = {
    development = "5.30.1"
    qa          = "5.29.0"
    integration = "5.29.0"
    preprod     = "5.29.0"
    production  = "5.29.0"
  }
}

variable "emr_applications" {
  description = "List of applications to deploy to EMR Cluster"
  type        = list(string)
  default     = ["Spark", "Hive", "Ganglia"]
}

variable "termination_protection" {
  description = "Default setting for Termination Protection"
  type        = bool
  default     = false
}

variable "keep_flow_alive" {
  description = "Indicates whether to keep job flow alive when no active steps"
  type        = bool
  default     = true //TODO set this to false when you want the cluster to autoterminate when final step completes
}

variable "truststore_aliases" {
  description = "comma seperated truststore aliases"
  type        = list(string)
  default     = ["dataworks_root_ca", "dataworks_mgt_root_ca"]
}

variable "emr_ami_id" {
  description = "AMI ID to use for the HBase EMR nodes"
}

variable "emr_instance_type" {
  default = {
    development = "m5.8xlarge"
    qa          = "m5.2xlarge"
    integration = "m5.8xlarge" # temp increase for DW-4437 testing
    preprod     = "m5.2xlarge"
    production  = "m5.2xlarge"
  }
}

variable "metadata_store_pdm_writer_username" {
  description = "Username for metadata store writer RDS user"
  default     = "pdm-writer"
}
