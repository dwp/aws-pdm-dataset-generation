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
  ${instance_fleets}
