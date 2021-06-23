locals {
  capacity_reservation_launch_specifications = {
    OnDemandSpecification = {
      AllocationStrategy = "lowest-price"
      CapacityReservationOptions = {
        CapacityReservationPreference = "open"
        UsageStrategy                 = "use-capacity-reservations-first"
      }
    }
  }

  ebs_config = {
    EbsBlockDeviceConfigs = [
      {
        VolumeSpecification = {
          SizeInGB   = 250
          VolumeType = "gp2"
        }
      }
    ]
    VolumesPerInstance = 1
  }

  instance_fleets_encoded = replace(yamlencode(local.instance_fleets[local.environment]), "/((?:^|\n)[\\s-]*)\"([\\w-]+)\":/", "$1$2:")

  instance_fleets_lower_environments = [
    {
      InstanceFleetType      = "MASTER"
      Name                   = "MASTER"
      TargetOnDemandCapacity = 1
      InstanceTypeConfigs = [
        {
          EbsConfiguration = local.ebs_config
          InstanceType     = "m5.4xlarge"
        }
      ]
    },
    {
      InstanceFleetType      = "CORE"
      Name                   = "CORE"
      TargetOnDemandCapacity = 10
      InstanceTypeConfigs = [
        {
          EbsConfiguration = local.ebs_config
          InstanceType     = "m5.2xlarge"
        }
      ]
    }
  ]
  instance_fleets = {
    development = local.instance_fleets_lower_environments
    qa          = local.instance_fleets_lower_environments
    integration = local.instance_fleets_lower_environments
    preprod = [
      {
        InstanceFleetType      = "MASTER"
        Name                   = "MASTER"
        TargetOnDemandCapacity = 1
        InstanceTypeConfigs = [
          {
            EbsConfiguration = local.ebs_config
            InstanceType     = "m5.16xlarge"
          }
        ]
      },
      {
        InstanceFleetType      = "CORE"
        Name                   = "CORE"
        TargetOnDemandCapacity = 39
        InstanceTypeConfigs = [
          {
            EbsConfiguration = local.ebs_config
            InstanceType     = "m5.16xlarge"
          }
        ]
      }
    ]
    production = [
      {
        InstanceFleetType      = "MASTER"
        Name                   = "MASTER"
        TargetOnDemandCapacity = 1
        LaunchSpecifications   = local.capacity_reservation_launch_specifications
        InstanceTypeConfigs = [
          {
            EbsConfiguration = local.ebs_config
            InstanceType     = "m5.16xlarge"
          }
        ]
      },
      {
        InstanceFleetType      = "CORE"
        Name                   = "CORE"
        TargetOnDemandCapacity = 39
        LaunchSpecifications   = local.capacity_reservation_launch_specifications
        InstanceTypeConfigs = [
          {
            EbsConfiguration = local.ebs_config
            InstanceType     = "m5.16xlarge"
          }
        ]
      }
    ]
  }
}
