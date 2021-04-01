---
Instances:
  KeepJobFlowAliveWhenNoSteps: ${keep_cluster_alive}
  AdditionalMasterSecurityGroups:
  - "${add_master_sg}"
  AdditionalSlaveSecurityGroups:
  - "${add_slave_sg}"
  Ec2SubnetId: "${subnet_id}"
  EmrManagedMasterSecurityGroup: "${master_sg}"
  EmrManagedSlaveSecurityGroup: "${slave_sg}"
  ServiceAccessSecurityGroup: "${service_access_sg}"
  InstanceFleets:
  - InstanceFleetType: "MASTER"
    Name: MASTER
    TargetOnDemandCapacity: 1
    LaunchSpecifications:
      OnDemandSpecification:
        AllocationStrategy: "lowest-price"
        CapacityReservationOptions:
          CapacityReservationPreference: "${capacity_reservation_preference}"
          UsageStrategy: "${capacity_reservation_usage_strategy}"
    InstanceTypeConfigs:
    - EbsConfiguration:
        EbsBlockDeviceConfigs:
        - VolumeSpecification:
            SizeInGB: 250
            VolumeType: "gp2"
          VolumesPerInstance: 1
      InstanceType: "${instance_type_master_one}"
  - InstanceFleetType: "CORE"
    Name: CORE
    TargetOnDemandCapacity: ${core_instance_capacity_on_demand}
    LaunchSpecifications:
      OnDemandSpecification:
        AllocationStrategy: "lowest-price"
        CapacityReservationOptions:
          CapacityReservationPreference: "${capacity_reservation_preference}"
          UsageStrategy: "${capacity_reservation_usage_strategy}"
    InstanceTypeConfigs:
    - EbsConfiguration:
        EbsBlockDeviceConfigs:
        - VolumeSpecification:
            SizeInGB: 250
            VolumeType: "gp2"
          VolumesPerInstance: 1
      InstanceType: "${instance_type_core_one}"
