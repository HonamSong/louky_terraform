# Main output

locals {
  #vpc_name            = var.vpc_create_flag == "0" ? var.vpc_name : "local_ss-vpc-vvv"

  flag_vpc_network_create = var.vpc_create_flag == "0" ? "Off" : "On"
  flag_addto_tgw_addr = var.AddTo_TGW_ADDR_flag == "0" ? "Off" : "On"
  flag_alb_create = var.alb_set_flag == "0" ? "Off" : "On"
  on_off_flag_lists   = ["FLAG_VPC_NETWORK_CREATE", "FLAG_ADDTO_TGW_ADDR", "FLAG_ALB_CREATE"]
  on_off_flag_values  = [local.flag_vpc_network_create, local.flag_addto_tgw_addr, local.flag_alb_create]
  on_off_flag         = formatlist("%-40s = %-5s", local.on_off_flag_lists, local.on_off_flag_values)

}


output "AWS_region_name" {
  value = data.aws_region.current.name
}

output "FLAG_ON_OFF_STATUS" {
  value = local.on_off_flag
}

####  Network VPC
output "Network_VPC_NAME" {
#  value = var.vpc_name
  value = var.vpc_create_flag == "0" ? var.vpc_name : local.vpc_tag_name
#  depends_on = [ module.icon_vpc.data.aws_vpc.get_vpc ]
}
output "Network_00_VPC_00_INFO" {
  value = module.icon_vpc.vpc_info
}
output "Network_00_VPC_01_ARN" {
  value = module.icon_vpc.vpc_info[0].arn
}
output "Network_00_VPC_02_ID" {
  value = module.icon_vpc.vpc_info[0].id
}
output "Network_00_VPC_03_CIDR" {
  value = module.icon_vpc.vpc_info[0].cidr_block
}


# subnet
output "Network_00_VPC_04_Subnet" {
  value = var.show_Network_00_VPC_04_Subnet == "true" ? module.icon_vpc.az_subnet : null
}

output "Network_00_VPC_05_Subnet_id" {
  value = module.icon_vpc.az_subnet[*].id
}

# internet_gateway (igw)
output "Network_01_IGW" {
  value = module.icon_vpc.igw_info
}

# routing table info
output "Network_02_RoutingTable_00-Default_Table" {
  value = module.icon_vpc.default_routing_table_info
}
output "Network_02_RoutingTable_01-info" {
  value = module.icon_vpc.routing_table_igw_info
}
output "Network_02_RoutingTable_02-AddToSubnet" {
  value = module.icon_vpc.add_routing_table_info
}

# Security group info
output "Network_03_SecurityGroup_01_ssh_port" {
  value = module.icon_vpc.sg_ssh
}
output "Network_03_SecurityGroup_02_alb_port" {
  value = module.icon_vpc.sg_alb
}
output "Network_03_SecurityGroup_03_websocket_port" {
  value = module.icon_vpc.sg_websocket
}
output "Network_03_SecurityGroup_04_ngrinder_port" {
  value = module.icon_vpc.sg_ngrinder
}

output "Network_04_LoadBalancer_FE_ALB" {
  value = module.icon_lb.LB_post_fe_alb
}
