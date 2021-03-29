variable "emr_release" {
  description = "Version of AWS EMR to deploy with associated applications"
  default = {
    development = "6.2.0"
    qa          = "6.2.0"
    integration = "6.2.0"
    preprod     = "6.2.0"
    production  = "6.2.0"
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

variable "emr_instance_type_master" {
  default = {
    development = "m5.16xlarge"
    qa          = "m5.16xlarge"
    integration = "m5.2xlarge"
    preprod     = "m5.2xlarge"
    production  = "m5.16xlarge"
  }
}

variable "emr_instance_type_core_one" {
  default = {
    development = "m5a.16xlarge"
    qa          = "m5a.16xlarge"
    integration = "m5a.2xlarge"
    preprod     = "m5a.2xlarge"
    production  = "m5a.16xlarge"
  }
}

variable "emr_instance_type_core_two" {
  default = {
    development = "m5.16xlarge"
    qa          = "m5.16xlarge"
    integration = "m5.2xlarge"
    preprod     = "m5.2xlarge"
    production  = "m5.16xlarge"
  }
}

variable "emr_instance_type_core_three" {
  default = {
    development = "r5a.16xlarge"
    qa          = "r5a.16xlarge"
    integration = "r5a.2xlarge"
    preprod     = "r5a.2xlarge"
    production  = "r5a.16xlarge"
  }
}

variable "emr_instance_type_core_four" {
  default = {
    development = "r5.16xlarge"
    qa          = "r5.16xlarge"
    integration = "r5.2xlarge"
    preprod     = "r5.2xlarge"
    production  = "r5.16xlarge"
  }
}

variable "metadata_store_pdm_writer_username" {
  description = "Username for metadata store writer RDS user"
  default     = "pdm-writer"
}

variable "emr_core_instance_count" {
  default = {
    development = "35"
    qa          = "35"
    integration = "2"
    preprod     = "2"
    production  = "35"
  }
}
