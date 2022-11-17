variable "emr_release" {
  description = "Version of AWS EMR to deploy with associated applications"
  default = {
    development = "6.8.0"
    qa          = "6.8.0"
    integration = "6.8.0"
    preprod     = "6.8.0"
    production  = "6.8.0"
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
  description = "AMI ID to use for the EMR nodes"
}

variable "emr_instance_type_master_one" {
  default = {
    development = "m5.4xlarge"
    qa          = "m5.4xlarge"
    integration = "m5.4xlarge"
    preprod     = "m5.16xlarge"
    production  = "m5.16xlarge"
  }
}

variable "emr_instance_type_core_one" {
  default = {
    development = "m5.2xlarge"
    qa          = "m5.2xlarge"
    integration = "m5.2xlarge"
    preprod     = "m5.4xlarge"
    production  = "m5.4xlarge"
  }
}

variable "metadata_store_pdm_writer_username" {
  description = "Username for metadata store writer RDS user"
  default     = "pdm-writer"
}

# This is weighted not a count of instances
variable "emr_core_instance_capacity_on_demand" {
  default = {
    development = "10"
    qa          = "10"
    integration = "10"
    preprod     = "40"
    production  = "40"
  }
}
