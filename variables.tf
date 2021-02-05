variable "emr_release" {
  description = "Version of AWS EMR to deploy with associated applications"
  default = {
    development = "5.30.1"
    qa          = "5.30.1"
    integration = "5.30.1"
    preprod     = "5.30.1"
    production  = "5.30.1"
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
    development = "m5.2xlarge"
    qa          = "m5.2xlarge"
    integration = "m5.2xlarge"
    preprod     = "m5.2xlarge"
    production  = "m5.16xlarge"
  }
}

variable "emr_instance_type_core_one" {
  default = {
    development = "m5.2xlarge"
    qa          = "m5.2xlarge"
    integration = "m5.2xlarge"
    preprod     = "m5.2xlarge"
    production  = "m5.24xlarge"
  }
}

variable "emr_instance_type_core_two" {
  default = {
    development = "m5a.2xlarge"
    qa          = "m5a.2xlarge"
    integration = "m5a.2xlarge"
    preprod     = "m5a.2xlarge"
    production  = "m5a.24xlarge"
  }
}

variable "emr_instance_type_core_three" {
  default = {
    development = "m5d.2xlarge"
    qa          = "m5d.2xlarge"
    integration = "m5d.2xlarge"
    preprod     = "m5d.2xlarge"
    production  = "m5d.24xlarge"
  }
}

variable "metadata_store_pdm_writer_username" {
  description = "Username for metadata store writer RDS user"
  default     = "pdm-writer"
}

variable "emr_core_instance_count" {
  default = {
    development = "2"
    qa          = "2"
    integration = "2"
    preprod     = "2"
    production  = "22"
  }
}

variable "image_version" {
  description = "Sha256 container version. Include sha256 prefix"
  default = {
    s3-object-tagger = "0.0.3"
  }
}
