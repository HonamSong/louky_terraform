# 1.1.7

module "icon_vpc" {
  source = "./icon-vpc"
  providers = {
	aws = aws.tokyo
  }
  # vpc
  vpc_name                 = var.vpc_name
  vpc_create_flag          = var.vpc_create_flag
  vpc_net_addr             = var.vpc_net_addr
  region_names             = var.region_names
  aws_region               = var.aws_region

  # subnet
  get_subnet_name_01       = var.get_subnet_name_01
  get_subnet_name_02       = var.get_subnet_name_02
  post_subnet_01_cidr_addr = var.post_subnet_01_cidr_addr
  post_subnet_02_cidr_addr = var.post_subnet_02_cidr_addr

  # igw
  igw_name                 = var.igw_name

  # routing_table
  igw_routing_table_name   = var.igw_routing_table_name

  # SecurityGroups
  # Dev-Net Gateway
  DGW_01_SVR_ADDR          = var.DGW_01_SVR_ADDR
  DGW_02_SVR_ADDR          = var.DGW_02_SVR_ADDR
  DGW_01_SVR_PUB_ADDR      = var.DGW_01_SVR_PUB_ADDR
  DGW_02_SVR_PUB_ADDR      = var.DGW_02_SVR_PUB_ADDR
  # Test-Net Gateway
  TGW_01_SVR_ADDR          = var.TGW_01_SVR_ADDR
  TGW_02_SVR_ADDR          = var.TGW_02_SVR_ADDR
  TGW_01_SVR_PUB_ADDR      = var.TGW_01_SVR_PUB_ADDR
  TGW_02_SVR_PUB_ADDR      = var.TGW_02_SVR_PUB_ADDR
}

module "icon_lb" {
  source    = "./icon-lb"
  providers = {
    aws = aws.tokyo
  }

  # Application LoadBalancer
  alb_set_flag             = var.alb_set_flag
  alb_name                 = var.alb_name
  alb_ssl_policy_name      = var.alb_ssl_policy_name
  alb_tg_name              = var.alb_tg_name
  alb_tg_port              = var.alb_tg_port
  alb_health_check_path    = var.alb_health_check_path
  alb_hc_interval          = var.alb_hc_interval
  alb_hc_threshold         = var.alb_hc_threshold
  alb_unhc_threshold       = var.alb_unhc_threshold

  cert_domain_name         = var.cert_domain_name
  cert_tag_name            = var.cert_tag_name

  module_vpc_info          = module.icon_vpc.vpc_info
  module_subnet_ids        = module.icon_vpc.az_subnet
  module_ec2_ids           = module.icon_ec2.print_ec2_ids            #### instance id !!
  module_sg_alb            = module.icon_vpc.sg_alb
}

module "icon_ec2" {
  source    = "./icon-ec2"
  providers = {
    aws = aws.tokyo
  }

  module_subnet_ids        = module.icon_vpc.az_subnet

  module_sg_ssh            = module.icon_vpc.sg_ssh
  module_sg_alb            = module.icon_vpc.sg_alb
  module_sg_websocket      = module.icon_vpc.sg_websocket
  module_sg_ngrinder       = module.icon_vpc.sg_ngrinder

  create_instance_count    = var.create_instance_count
  ctz_node_count           = var.ctz_node_count
  last_instance_set_flag   = var.last_instance_set_flag
  create_ctz_set_flag      = var.create_ctz_set_flag

  aws_instance_type        = var.aws_instance_type

  root_vol_type            = var.root_vol_type
  root_vol_size            = var.root_vol_size
  root_vol_iops            = var.root_vol_iops
  root_vol_throughput      = var.root_vol_throughput

  ebs_blockdevice_set_flag = var.ebs_blockdevice_set_flag
  ebs_vol_type             = var.ebs_vol_type
  ebs_vol_size             = var.ebs_vol_size
  ebs_vol_iops             = var.ebs_vol_iops
  ebs_vol_throughput       = var.ebs_vol_throughput

  ec2_keypair_name         = var.ec2_keypair_name

  tag_Team                 = var.tag_Team
  tag_User                 = var.tag_User
  tag_Role                 = var.tag_Role
  tag_Env                  = var.tag_Env
  tag_Product              = var.tag_Product
  tag_Ec2schedulermsg      = var.tag_Ec2schedulermsg
  tag_TargetGroups         = var.tag_TargetGroups
  tag_OperatingSystem      = var.tag_OperatingSystem

  ami_name                 = var.ami_name
  default_ami              = var.default_ami
  aws_ami_owner            = var.aws_ami_owner
  iam_role_name            = var.iam_role_name

}
