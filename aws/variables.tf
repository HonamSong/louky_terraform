# common variables
variable "aws_region"                { default = "ap-northeast-1" }
variable "network_node_name"         { default = "TerraformNet" } ### modify
variable "instance_name"             { default = "peer" }         ### modify
variable "ctz_instance_name"         { default = "ctz" }
variable "last_instance_name"        { default = "trk" }

## variables is get vpc values
variable "module_vpc_info"           { default = "" }
variable "module_subnet_ids"         { default = "" }
variable "module_ec2_ids"            { default = "" }
variable "module_sg_ssh"             { default = "" }
variable "module_sg_alb"             { default = "" }
variable "module_sg_websocket"       { default = "" }
variable "module_sg_ngrinder"        { default = "" }

locals {
  ###  type ==>>   1 : test / 2 : Develop / 3 : real
#  region_name_rule = (
#      var.deploy_type == "1" ?                                    # if
#        var.region_names[var.aws_region]["test_name_rule"] :
#      var.deploy_type == "2" ?                                    # elif
#        var.region_names[var.aws_region]["dev_name_rule"] :
#      var.deploy_type == "3" ?                                    # elif
#        var.region_names[var.aws_region]["real_name_rule"] :
#      ""                                                          # else
#    )
  region_name_rule     = var.deploy_type == "1" ? var.region_names[var.aws_region]["test_name_rule"] : local.dev_name_rule
  dev_name_rule        = var.deploy_type == "2" ? var.region_names[var.aws_region]["dev_name_rule"] : local.real_name_rule
  real_name_rule       = var.deploy_type == "3" ? var.region_names[var.aws_region]["real_name_rule"] : ""

  #vpc_tag_name = "${local.region_name_rule}-${var.network_node_name}-vpc-${var.aws_vpc_net_addr}"
  vpc_tag_name         = "${var.vpc_name}-vpc-${var.vpc_net_addr}"
  igw_tag_name         = "${var.vpc_name}-${var.igw_name}"

  # routing_table tag name
  default_rt_tag_name  = "${var.vpc_name}-routing-${var.vpc_net_addr}"
  rt_tag_name          = "${var.vpc_name}-${var.igw_routing_table_name}"

  # security group config
  ## tag name
  sg_tag_name          = "${var.network_node_name}_${var.sg_name}"

}

###  Test(1) , Develop(2), Real(3)
variable "deploy_type"       { default = "1" } ### type 1:test, 2:develop, 3:real
variable "region_names" {
  description = "Default "
  type        = map(any)
  default = {
	"us-west-1" = {
	  ### California region
	  az_01          = "us-west-1a"
	  az_02          = "us-west-1b"
	  test_name_rule = "acat"
	  dev_name_rule  = "acad"
	  real_name_rule = "acar"
	}

	"us-west-2" = {
	  ### Oregon region
	  az_01          = "us-west-2a"
	  az_02          = "us-west-2b"
	  test_name_rule = "aort"
	  dev_name_rule  = "aord"
	  real_name_rule = "aorr"
	}

	"ap-northeast-2" = {
	  ### Korea region
	  az_01          = "ap-northeast-2a"
	  az_02          = "ap-northeast-2c"
	  test_name_rule = "akrt"
	  dev_name_rule  = "akrd"
	  real_name_rule = "akrr"
	}

	"ap-northeast-1" = {
	  ### Tokyo region
	  az_01          = "ap-northeast-1a"
	  az_02          = "ap-northeast-1d"
	  test_name_rule = "ajpt"
	  dev_name_rule  = "ajpd"
	  real_name_rule = "ajpr"
	}

	"ap-southeast-1" = {
	  ### Singapore region
	  az_01          = "ap-southeast-1a"
	  az_02          = "ap-southeast-1b"
	  test_name_rule = "asgt"
	  dev_name_rule  = "asgd"
	  real_name_rule = "asgr"
	}

	"ap-southeast-2" = {
	  ### Sydney region
	  az_01          = "ap-southeast-2a"
	  az_02          = "ap-southeast-2b"
	  test_name_rule = "asyt"
	  dev_name_rule  = "asyd"
	  real_name_rule = "asyr"
	}

	"ap-east-1" = {
	  ### HongKong region
	  az_01          = "ap-east-1a"
	  az_02          = "ap-east-1c"
	  test_name_rule = "ahkt"
	  dev_name_rule  = "ahkd"
	  real_name_rule = "ahkr"
	}

	"ap-south-1" = {
	  ### Mumbai region
	  az_01          = "ap-south-1a"
	  az_02          = "ap-south-1b"
	  test_name_rule = "ambt"
	  dev_name_rule  = "ambd"
	  real_name_rule = "ambr"
	}

	"us-east-1" = {
	  ### Virginia region
	  az_01          = "us-east-1a"
	  az_02          = "us-east-1c"
	  test_name_rule = "avat"
	  dev_name_rule  = "avad"
	  real_name_rule = "avar"
	}

	"us-east-2" = {
	  ### Ohio region
	  az_01          = "us-east-2a"
	  az_02          = "us-east-2c"
	  test_name_rule = "aoht"
	  dev_name_rule  = "aohd"
	  real_name_rule = "aohr"
	}

	"eu-central-1" = {
	  ### Frankfurt region
	  az_01          = "eu-central-1a"
	  az_02          = "eu-central-1c"
	  test_name_rule = "afft"
	  dev_name_rule  = "affd"
	  real_name_rule = "affr"
	}

	"eu-west-2" = {
	  ### London region
	  az_01          = "eu-west-2a"
	  az_02          = "eu-west-2b"
	  test_name_rule = "aldt"
	  dev_name_rule  = "aldd"
	  real_name_rule = "aldr"
	}
  }
}

# VPC variables
## vpc.tf
variable "vpc_create_flag"           { default = "0" }
variable "vpc_name"                  { default = "goloop-poc-jp-vpc" }
variable "vpc_net_addr"              { default = "10.232.0.0/16" }      ### modify

### subnet.tf
variable "get_subnet_name_01"        { default = "goloop-poc-jp-10.60.0.0/24" } ### modify
variable "get_subnet_name_02"        { default = "goloop-poc-jp-10.60.1.0/24" } ### modify
variable "post_subnet_01_cidr_addr"  { default = "10.232.100.0/24" } ### modify
variable "post_subnet_02_cidr_addr"  { default = "10.232.200.0/24" } ### modify

### igw.tf
variable "igw_name"                  { default = "igw" } ### modify

### routing_table.tf
variable "igw_routing_table_name"    { default = "igw-rt" }

### Security Group / sg.tf
variable "sg_name"                   { default = "sg-01" }
## Add IP address
### 아이콘루프 퍼블릭 ADDRESS - SKT 회선
variable "IL_PUB_ADDR_SKT"           { default = "58.234.156.141/32" }
variable "IL_VPN_ADDR_SKT"           { default = "58.234.156.144/32" }
variable "IL_LAN_ADDR_SKT"           { default = "58.234.156.140/32" }    ## LAN (Vmware)

### 아이콘루프 퍼블릭 ADDRESS - KT 회선
variable "IL_PUB_ADDR_KT"            { default = "121.128.68.241/32" }
variable "IL_VPN_ADDR_KT"            { default = "121.128.68.245/32" }
variable "IL_LAN_ADDR_KT"            { default = "121.128.68.240/32" }    ## LAN (Vmware)

### Default tbridge gateway server ip
variable "DGW_01_SVR_ADDR"          { default = "172.31.15.241/32" }     ### DGW01
variable "DGW_02_SVR_ADDR"          { default = "172.31.25.62/32" }      ### DGW02
variable "DGW_01_SVR_PUB_ADDR"      { default = "13.209.180.15/32" }     ### DGW01
variable "DGW_02_SVR_PUB_ADDR"      { default = "52.79.36.251/32" }      ### DGW02

variable "AddTo_TGW_ADDR_flag"      { default = 0 }
variable "TGW_01_SVR_ADDR"          { default = "172.31.20.246/32" }     ### T-GW01
variable "TGW_02_SVR_ADDR"          { default = "172.31.23.163/32" }     ### T-GW02
variable "TGW_01_SVR_PUB_ADDR"      { default = "13.124.36.111/32" }     ### T-GW01
variable "TGW_02_SVR_PUB_ADDR"      { default = "13.209.140.46/32" }     ### T-GW02


#==================================================================================================
## load-balancer variables


### Application LoadBalancer
variable "alb_set_flag"             { default = 0 }
variable "alb_name"                 { default = "alb-01" }
variable "alb_ssl_policy_name"      { default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06" }
variable "alb_tg_name"              { default = "alb-tg-01" }
variable "alb_tg_port"              { default = 9000 }
variable "alb_health_check_path"    { default = "/" }
variable "alb_hc_interval"          { default = 10 }
variable "alb_hc_threshold"         { default = 3 }
variable "alb_unhc_threshold"       { default = 2 }

### Certification variable
variable "cert_domain_name"         { default = "*.net.solidwallet.io" } ### modify
variable "cert_tag_name"            { default = "terraform_init_cert" }  ### modify




#========================================================================================================
## EC2 instances

variable "create_instance_count"    { default = "0" }
variable "aws_instance_type"        { default = "c5.2xlarge" }
variable "ctz_node_count"           { default = 0 }

variable "last_instance_set_flag"   { default = 0 }
variable "create_ctz_set_flag"      { default = 0 }

variable "root_vol_type"            { default = "gp3" }
variable "root_vol_size"            { default = "20" }
variable "root_vol_iops"            { default = "3000" }
variable "root_vol_throughput"      { default = "125" }

variable "ebs_blockdevice_set_flag" { default = "false" }
variable "ebs_vol_type"             { default = "gp3" }
variable "ebs_vol_size"             { default = "20" }
variable "ebs_vol_iops"             { default = "3000" }
variable "ebs_vol_throughput"       { default = "125" }

variable "ec2_keypair_name"         { default = "tbridge"}

variable "tag_Team"                 { default = "Infra" }
variable "tag_User"                 { default = "Infra" }
variable "tag_Role"                 { default = "peer" }
variable "tag_Env"                  { default = "TerraformTest" }
variable "tag_Product"              { default = "goloop" }
variable "tag_Ec2schedulermsg"      { default = "" }
variable "tag_TargetGroups"         { default = "" }
variable "tag_OperatingSystem"      { default = "" }

variable "ami_name" {
  description = "You can either choose the AWS AMI image."
  default     = "self_amazon_linux"
}

variable "default_ami" {
  description = "Default Get AMI info"
  type        = map(any)
  default = {
	"self_amazon_linux" = {
	  owner_id     = "self"
	  alias_name   = "self"
	  name         = "amazon-ami"
	  filter_name  = "amazon-ami*"
	  arch_type    = "x86_64"
	  default_user = "ec2-user"
	}

	"amazon_linux" = {
	  owner_id     = "amazon"
	  alias_name   = "amazon"
	  name         = "amzn2-ami-hvm"
	  filter_name  = "amzn2-ami-hvm*"
	  arch_type    = "x86_64"
	  default_user = "ec2-user"
	}

	"centos_6" = {
	  owner_id     = "679593333241"
	  alias_name   = "aws-marketplace"
	  name         = "CentOS Linux 6"
	  filter_name  = "CentOS Linux 6*"
	  arch_type    = "x86_64"
	  default_user = "centos"
	}

	"centos_7" = {
	  owner_id     = "679593333241"
	  alias_name   = "aws-marketplace"
	  name         = "CentOS Linux 7"
	  filter_name  = "CentOS Linux 7*"
	  arch_type    = "x86_64"
	  default_user = "centos"
	}

	"centos_8" = {
	  owner_id     = "679593333241"
	  alias_name   = "aws-marketplace"
	  name         = "CentOS-8-ec2"
	  filter_name  = "*CentOS-8-ec2*"
	  arch_type    = "x86_64"
	  default_user = "centos"
	}

	"ubuntu_16.04" = {
	  owner_id     = "aws-marketplace"
	  alias_name   = "aws-marketplace"
	  name         = "ubuntu-xenial-16.04-amd64-server"
	  filter_name  = "*ubuntu-xenial-16.04*"
	  arch_type    = "x86_64"
	  default_user = "ubuntu"
	}

	"ubuntu_18.04" = {
	  owner_id     = "aws-marketplace"
	  alias_name   = "aws-marketplace"
	  name         = "ubuntu-bionic-18.04-amd64-server"
	  filter_name  = "*ubuntu-bionic-18.04*"
	  arch_type    = "x86_64"
	  default_user = "ubuntu"
	}

	"ubuntu_20.04" = {
	  owner_id     = "aws-marketplace"
	  alias_name   = "aws-marketplace"
	  name         = "ubuntu-focal-20.04-amd64-server"
	  filter_name  = "*ubuntu-focal-20.04*"
	  arch_type    = "x86_64"
	  default_user = "ubuntu"
	}
  }
}

### AMI owner
variable "aws_ami_owner" { default = "229930918337" }

###  IAM  ROLE NAME
variable "iam_role_name" { default = "EC2RoleForSSM" }

### print flag
variable "show_Network_00_VPC_04_Subnet" { default = "true"}