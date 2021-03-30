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
    development = "r5a.12xlarge"
    qa          = "r5a.12xlarge"
    integration = "r5a.large"
    preprod     = "r5a.large"
    production  = "r5a.12xlarge"
  }
}

variable "emr_instance_type_core_one" {
  default = {
    development = "r5.4xlarge"
    qa          = "r5.4xlarge"
    integration = "r5.4xlarge"
    preprod     = "r5.4xlarge"
    production  = "r5.12xlarge"
  }
}

variable "emr_instance_type_weighting_core_one" {
  default = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "5"
    production  = "5"
  }
}

variable "emr_instance_type_core_two" {
  default = {
    development = "r5a.4xlarge"
    qa          = "r5a.4xlarge"
    integration = "r5a.4xlarge"
    preprod     = "r5a.4xlarge"
    production  = "r5a.12xlarge"
  }
}

variable "emr_instance_type_weighting_core_two" {
  default = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "5"
    production  = "5"
  }
}

variable "emr_instance_type_core_three" {
  default = {
    development = "r5d.4xlarge"
    qa          = "r5d.4xlarge"
    integration = "r5d.4xlarge"
    preprod     = "r5d.4xlarge"
    production  = "r5d.12xlarge"
  }
}

variable "emr_instance_type_weighting_core_three" {
  default = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "5"
    production  = "5"
  }
}

variable "emr_instance_type_core_four" {
  default = {
    development = "m5.8xlarge"
    qa          = "m5.8xlarge"
    integration = "m5.8xlarge"
    preprod     = "m5.8xlarge"
    production  = "m5.24xlarge"
  }
}

variable "emr_instance_type_weighting_core_four" {
  default = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "5"
    production  = "5"
  }
}

variable "emr_instance_type_core_five" {
  default = {
    development = "i3en.3xlarge"
    qa          = "i3en.3xlarge"
    integration = "i3en.3xlarge"
    preprod     = "i3en.3xlarge"
    production  = "i3en.12xlarge"
  }
}

variable "emr_instance_type_weighting_core_five" {
  default = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "5"
    production  = "5"
  }
}

variable "metadata_store_pdm_writer_username" {
  description = "Username for metadata store writer RDS user"
  default     = "pdm-writer"
}

# This is weighted not a count of instances
variable "emr_core_instance_capacity_on_demand" {
  default = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "5"
    production  = "25"
  }
}

# This is weighted not a count of instances
variable "emr_core_instance_capacity_spot" {
  default = {
    development = "45"
    qa          = "45"
    integration = "45"
    preprod     = "45"
    production  = "150"
  }
}

# Time needed to block spots for so they are not destroyed
variable "emr_spot_block_duration_minutes" {
  default = {
    development = "60"
    qa          = "60"
    integration = "60"
    preprod     = "60"
    production  = "360"
  }
}

# Time to wait for spot instances before the fall back method is invoked
variable "emr_spot_timeout_duration_minutes" {
  default = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "5"
    production  = "20"
  }
}
