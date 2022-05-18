#### Terraform v0.14.7


####  terraform.tfvars 에서 변수값을 수정한다. 

####################################################################
#### create network
##################################################################

module "aws-network-configs" { ## 수정 (modify)
  source = "network-configs"

  providers = {
    aws = aws ## 수정 (modify)
    # aws = aws.tokyo ## 수정 (modify) 다른 리전
    # aws = aws.switch_role_turing ## 수정 (modify), 다른 계정
  }

  aws_region			= var.aws_region
  region_names			= var.region_names

  network_node_name		= var.network_node_name

  vpc_name          	= var.vpc_name

  subnet_name_01		= var.subnet_name_01
  subnet_name_02		= var.subnet_name_02

  # routing table
  igw_routing_table_name 	= var.igw_routing_table_name

  ## SKT
  IL_PUB_ADDR_SKT		= var.IL_PUB_ADDR_SKT
  IL_VPN_ADDR_SKT		= var.IL_VPN_ADDR_SKT
  IL_LAN_ADDR_SKT		= var.IL_LAN_ADDR_SKT

  ## KT Line
  IL_PUB_ADDR_KT		= var.IL_PUB_ADDR_KT
  IL_VPN_ADDR_KT		= var.IL_VPN_ADDR_KT
  IL_LAN_ADDR_KT		= var.IL_LAN_ADDR_KT

  ###  Gateway Server 
  GW_01_SVR_ADDR		= var.GW_01_SVR_ADDR
  GW_02_SVR_ADDR		= var.GW_02_SVR_ADDR 
  GW_01_SVR_PUB_ADDR	= var.GW_01_SVR_PUB_ADDR
  GW_02_SVR_PUB_ADDR	= var.GW_02_SVR_PUB_ADDR

  ## Add EIP Addresss SG
  module_eip_ips		= module.aws-ec2-configs.print_eip_public_ips

  ## ++ Cert
  cert_domain_name		= var.cert_domain_name
  cert_tag_name			= var.cert_tag_name

  ## ++  Load Balancer
  lb_alb_name			= var.lb_alb_name

  ## ++ Load Balancer Target
  lb_alb_tg_name		= var.lb_alb_tg_name
  lb_tg_port			= var.lb_tg_port
  tg_healthcheck_protocol	= var.tg_healthcheck_protocol

  ### Target Group add Instance ids
  create_instance_count	= var.create_instance_count
  #module_instance_ids	= module.aws-ec2-configs.Instance_ids    ### OLD config
  module_instance_ids	= module.aws-ec2-configs.print_ec2_ids

  ## ++ Load Balancer Health Check PATH
  health_check_path		= var.health_check_path

  ## ++  Security Group
  sg_name			    = var.sg_name

  ## flag 
  vpc_create_flag		= var.vpc_create_flag
  route53_set_flag		= var.route53_set_flag
  lb_set_flag			= var.lb_set_flag
  pri_ip_set_flag		= var.pri_ip_set_flag

}



#######  ########    ######   ######        ####################################################################
#######  ##         ##             #        ####################################################################
#######  ########   ##         ###          ####################################################################
#######  ##         ##        #             ####################################################################
#######  ########    ######   ######        ####################################################################

#### create ec2 instance...

##+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
module "aws-ec2-configs" { 		## 수정 (modify)
  source = "ec2-configs"

  providers = {
    aws = aws 				## 수정 (modify)
    # aws = aws.tokyo ## 수정 (modify) 다른 리전
    # aws = aws.switch_role_turing ## 수정 (modify), 다른 계정
  }

  aws_region                = var.aws_region
  region_names              = var.region_names

  default_ami               = var.default_ami 				## 수정 (modify) default image = amazon_linux
  ami_name                  = var.ami_name    				## AMI LIST(사전 정의) => self_amazon_linux / amazon_linux / centos_6 / centos_7 / cnetos_8 / ubuntu_16.04 / ubuntu_18.04 / ubuntu_20.04

  aws_instance_type         = var.aws_instance_type

  create_instance_count     = var.create_instance_count 		## 수정 (modify

  network_node_name         = var.network_node_name 			## 수정 (modify)
  deploy_type               = var.deploy_type
  instance_name             = var.instance_name
  last_instance_name        = var.last_instance_name

  instance_root_vol_type	= var.instance_root_vol_type
  instance_root_vol_size 	= var.instance_root_vol_size
  root_vol_iops			    = var.root_vol_iops

  ec2_keypair_name 		    = var.ec2_keypair_name

  ##get network module
  module_subnet_id          = [module.aws-network-configs.az_subnet_01, module.aws-network-configs.az_subnet_02]
  module_subnet_cidr        = [module.aws-network-configs.print_subnet_cidr_01, module.aws-network-configs.print_subnet_cidr_02]

  module_sg_ssh      		= module.aws-network-configs.sg_ssh
  module_sg_websocket 		= module.aws-network-configs.sg_websocket
  module_sg_alb      		= module.aws-network-configs.sg_alb
  module_sg_ngrinder      	= module.aws-network-configs.sg_ngrinder
  module_sg_websocket_9900 	= module.aws-network-configs.sg_websocket_9900
  module_sg_websocket_9999 	= module.aws-network-configs.sg_websocket_9999
  module_sg_websocket_8081_8090 	= module.aws-network-configs.sg_websocket_8081_8090

  ## ++ flag 
  vpc_create_flag		= var.vpc_create_flag
  route53_set_flag		= var.route53_set_flag
  lb_set_flag			= var.lb_set_flag
  pri_ip_set_flag		= var.pri_ip_set_flag
  last_instance_set_flag	= var.last_instance_set_flag

  ## ++ Private start IP address 
  start_private_ip		= var.start_private_ip

  ## ++ Tag Value
  tag_Team            		= var.tag_Team
  tag_User            		= var.tag_User
  tag_Role            		= var.tag_Role
  tag_Env             		= var.tag_Env
  tag_Poc             		= var.tag_Poc
  tag_Product         		= var.tag_Product
  tag_Ec2schedulermsg 		= var.tag_Ec2schedulermsg


  create_ctz_flag           = var.create_ctz_flag
  ctz_node_instance_name    = var.ctz_node_instance_name
  ctz_node_count            = var.ctz_node_count

}

