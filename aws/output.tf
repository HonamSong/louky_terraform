### Terraform v0.14.7
### https://velog.io/@bhs9610/Terraform-%EB%B0%98%EB%B3%B5%EB%AC%B8-%EC%9C%BC%EB%A1%9C-%EB%8B%A4%EC%A4%91-EC2-%EB%A7%8C%EB%93%A4%EA%B8%B0

locals {
  vpc_name = var.vpc_create_flag == "0" ? var.vpc_name : "${local.region_name_rule}-${var.network_node_name}-vpc-${var.aws_vpc_net_addr}"

  ami_infos = concat(module.aws-ec2-configs.ami_arn, module.aws-ec2-configs.ami_image_location, module.aws-ec2-configs.ami_architecture, module.aws-ec2-configs.ami_id, module.aws-ec2-configs.ami_image_name)

  all_ips = try(
    formatlist("%-16s , %-16s", module.aws-ec2-configs.print_eip_private_ips, module.aws-ec2-configs.print_eip_public_ips)
  )

  ec2_all_name_ip = try(
    #sort (formatlist("%-30s , %-16s , %-16s", module.aws-ec2-configs.print_instance_name, module.aws-ec2-configs.print_eip_private_ips, module.aws-ec2-configs.print_eip_public_ips))
    #sort(formatlist("%-30s , %-16s , %-16s", module.aws-ec2-configs.print_instance_name, module.aws-ec2-configs.print_private_ips, module.aws-ec2-configs.print_public_ips))
    sort(formatlist("%-30s , %-16s , %-16s", module.aws-ec2-configs.print_instance_name, module.aws-ec2-configs.print_private_ips, module.aws-ec2-configs.print_sort_eip))
  )

  get_instance_type = try(
    sort(formatlist("%-30s, %-16s", module.aws-ec2-configs.print_instance_name, module.aws-ec2-configs.print_instanceType_real))
  )

  flag_ec2_instance_private_ip_setting = var.pri_ip_set_flag == "0" ? "Off" : "On"
  flag_network_create                  = var.vpc_create_flag == "0" ? "Off" : "On"
  flag_loadbalancer_create             = var.lb_set_flag == "0" ? "Off" : "On"
  flag_route53_setting			= var.route53_set_flag == "0" ? "Off" : (var.lb_set_flag == "1" ? "On" : "Off (Change Flag On to Off, because flag OFF for lb_set_flag)")
  flag_last_node_setting		= var.last_instance_set_flag == "0" ? "Off" : "On"
  flag_create_ctz_flag		= var.create_ctz_flag == "0" ? "Off" : "On"

  #on_off_flag = formatlist("%-40s = %-5s", ["FLAG_EC2_INSTANCE_PRIVATE_IP_SETTING", "FLAG_LOADBALANCER_CREATE", "FLAG_VPC_NETWORK_CREATE", "FLAG_ROUTE53_SETTING", "FLAG_LAST_NODE_SETTING"], [local.flag_ec2_instance_private_ip_setting, local.flag_loadbalancer_create, local.flag_network_create, local.flag_route53_setting, local.flag_last_node_setting])
  on_off_flag = formatlist("%-40s = %-5s", ["FLAG_EC2_INSTANCE_PRIVATE_IP_SETTING", "FLAG_LOADBALANCER_CREATE", "FLAG_VPC_NETWORK_CREATE", "FLAG_ROUTE53_SETTING", "FLAG_LAST_NODE_SETTING","FLAG_CREATE_CTZ_FLAG"], [local.flag_ec2_instance_private_ip_setting, local.flag_loadbalancer_create, local.flag_network_create, local.flag_route53_setting, local.flag_last_node_setting,local.flag_create_ctz_flag])

  route53_info = formatlist("%-40s = %-5s", ["zone_name", "zond_id", "Add_DNS_NAME", "recode_name", "recode_fqdn"], [var.dns_zone_name, module.aws-network-configs.print_route53_zone_id, local.route53_recode_name, module.aws-network-configs.print_route53_add_name, module.aws-network-configs.print_route53_add_fqdn])

  lb_info = formatlist("%-25s = %-s", ["LoadBalancer_ID", "LoadBalancer_DNS_NAME"], [module.aws-network-configs.LoadBalancer_id, module.aws-network-configs.LoadBalancer_dnsname])

  ssh_conn_info = formatlist("ssh -i ~/aws-key/%s %s@%s", var.ec2_keypair_name, var.default_ami[var.ami_name]["default_user"], module.aws-ec2-configs.print_eip_public_ips)
}




## Region print 
output "AWS_region_name" {
  value = data.aws_region.current.name
}

output "FLAG_ON_OFF_STATUS" {
  value = local.on_off_flag
}


output "EC2_ssh_keypair_name" {
  value = var.ec2_keypair_name
}

output "EC2_Instance_tags" {
  value = local.ec2_instance_tags
}


#### AMI Info
output "EC2_AMI_info" {
  value = local.ami_infos
}

#### result ec2 EIP 

output "EC2_Instance_info" {
  value = local.ec2_all_name_ip
}

output "EC2_Instance_name" {
  value = module.aws-ec2-configs.print_instance_name
}

output "EC2_Peer_Instance_IDs" {
  value = module.aws-ec2-configs.print_ec2_ids
}

output "EC2_all_ips" {
  value = local.all_ips
}

# IAM ROLE
output "EC2_iam_role_attach_name" {
  value = module.aws-ec2-configs.print_iam_role_name
}


output "EC2_Instance_type_config" {
  value = var.aws_instance_type
}

output "EC2_Instance_type_real" {
  value = local.get_instance_type
}




###  VPC Info

output "Network_VPC_Name" {
  value = local.vpc_name
}

output "Network_VPC_Info" {
  value = module.aws-network-configs.vpc_info
}

## Load Balance INFO
output "Network_LoadBalancer_INFO" {
  value = local.lb_info
}

### route53
output "route53_info" {
  value = local.route53_info
}

output "za_IP_JSON_Public" {
  value = module.aws-ec2-configs.print_eip_public_ips
}
output "za_IP_JSON_Private" {
  value = module.aws-ec2-configs.print_eip_private_ips
}

output "za_IP_JSON_Public_sort" {
  value = module.aws-ec2-configs.print_sort_eip
}


####  ssh connection command
output "zz_ssh_conn_info" {
  value = local.ssh_conn_info
}

output "zz_test_count" {
  value = format("%02d", var.create_instance_count)
}

output "zz_print_ctz_count" {
  value = module.aws-ec2-configs.print_ctz_count
}
output "zz_print_last_count" {
  value = module.aws-ec2-configs.print_last_count
}
