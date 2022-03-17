#### Terraform v0.14.7


##	 ____  _____ ____ ___ ___  _   _   _   _    _    __  __ _____
##	|  _ \| ____/ ___|_ _/ _ \| \ | | | \ | |  / \  |  \/  | ____|
##	| |_) |  _|| |  _ | | | | |  \| | |  \| | / _ \ | |\/| |  _|
##	|  _ <| |__| |_| || | |_| | |\  | | |\  |/ ___ \| |  | | |___
##	|_| \_\_____\____|___\___/|_| \_| |_| \_/_/   \_\_|  |_|_____|
##	
### AWS Region 
variable "aws_region" { default = "us-west-1" }
variable "aws_region_alias" { default = "jp" }


# ___             _                         _   _
#|_ _|_ __   __ _| |_ __ _ _ __   ___ ___  | \ | | __ _ _ __ ___   ___
# | || '_ \ / _` | __/ _` | '_ \ / __/ _ \ |  \| |/ _` | '_ ` _ \ / _ \
# | || | | | (_| | || (_| | | | | (_|  __/ | |\  | (_| | | | | | |  __/
#|___|_| |_|\__,_|\__\__,_|_| |_|\___\___| |_| \_|\__,_|_| |_| |_|\___|
##Instance name  => ${local.region_name_rule}-${var.network_node_name}-${var.instance_name}-${element(var.instance_index_az_01, count.index)}
##  ex) variable "network_node_name" 	{ default = "terraform-net"}		### modify 
##  ex) variable "instance_name" 	{ default = "peer" }			### modify
##  ex) result >>>  acat-terraformnet-peer-01

variable "network_node_name" 	{ default = "TerraformNet" } 		### modify
variable "instance_name" 		{ default = "peer" }         		### modify



##	  ___  _   _      __   ___  _____ _____   _____ _        _    ____
##	 / _ \| \ | |    / /  / _ \|  ___|  ___| |  ___| |      / \  / ___|
##	| | | |  \| |   / /  | | | | |_  | |_    | |_  | |     / _ \| |  _
##	| |_| | |\  |  / /   | |_| |  _| |  _|   |  _| | |___ / ___ \ |_| |
##	 \___/|_| \_| /_/     \___/|_|   |_|     |_|   |_____/_/   \_\____|
###  On/OFF flag

#+++  VPC create flag
# 0  => Not create,   1 => create
variable "vpc_create_flag" 		{ default = "0" }

# +++  Load Balancer create flag
# 0  => disable(off),  1 => enable(on)
variable "lb_set_flag" 			{ default = "0" }

# +++  Load balancer health Check path
variable "health_check_path" 	{ default = "/" }

# +++  Instance Private IP setting On/Off flag
# 0 =>  DHCP On , 1 => DHCP Off(Static IP Setting)
variable "pri_ip_set_flag" 		{ default = "1" }

# +++  Route53 Set On/Off flag
# 0 => disable(off),  1 => enable(on)
variable "route53_set_flag" 		{ default = "0" }

# +++ other node setting flag of the last instance : 마지막 인스턴스의 별도 노드 설정 플래그
# 0 => disable(off),  1 => enable(on)
variable "last_instance_set_flag" 	{ default = "1" }
variable "last_instance_name" 		{ default = "tracker" } 


# +++ ctz node
# 0 => disable(off),  1 => enable(on)
variable "create_ctz_flag"		    { default = "0" }
# Create ctz node count
variable "ctz_node_count"		    { default = "0" }
variable "ctz_node_instance_name"	{ default = "ctz" }



##	__     ______   ____
##	\ \   / /  _ \ / ___|
##	 \ \ / /| |_) | |
##	  \ V / |  __/| |___
##	   \_/  |_|    \____|
##################################################
### VPC Not Create variables
## ex) variable "vpc_name" 		{ default = "goloop-poc-10.230.0.0/16" }
## ex) variable "subnet_name_01" 	{ default = "goloop-poc" }
## ex) variable "subnet_name_02" 	{ default = "goloop-poc" }

# 사용 또는 매칭 할 수 있는 VPC & SUBNET 이름을 입력한다.
variable "vpc_name"       { default = "VPC" }     ### modify
variable "subnet_name_01" { default = "Subnet" }  ### modify
variable "subnet_name_02" { default = "Subnet" }  ### modify

# +++++++++++++++++++++++++++++++++++++++++++++++++++
# VPC  Create variables
variable "aws_vpc_net_addr"     { default = "10.232.0.0/16" }     ### modify
variable "subnet_01_cidr_addr"  { default = "10.232.100.0/24" }   ### modify
variable "subnet_02_cidr_addr"  { default = "10.232.200.0/24" }   ### modify

# Internet gateway setting
variable "igw_name" { default = "igw" } ### modify



##	 ___ _   _ ____ _____  _    _   _  ____ _____
##	|_ _| \ | / ___|_   _|/ \  | \ | |/ ___| ____|
##	 | ||  \| \___ \ | | / _ \ |  \| | |   |  _|
##	 | || |\  |___) || |/ ___ \| |\  | |___| |___
##	|___|_| \_|____/ |_/_/   \_\_| \_|\____|_____|

##### Create Ec2 instance count
variable "create_instance_count" { default = "2" }


### EC2 Instance deploy Type
###  Test(1) , Develop(2), Real(3)
variable "deploy_type" { default = "1" } ### type 1:test, 2:develop, 3:real

## ECE Instance type 
###  c5.xlarge, c5.2xlarge, c5.4xlarge
variable "aws_instance_type" { default = "t2.micro" }

## root device default volume type - gp2 ... gp3
variable "instance_root_vol_type" { default = "gp3" } ### modify

## root device default size (GB)
variable "instance_root_vol_size" { default = "20" } ### modify

## root device default iops
variable "root_vol_iops" { default = "128" } ### modify


###  IAM  ROLE NAME 
variable "iam_role_name" { default = "EC2RoleForSSM" }


##	 _____                        _
##	|_   _|_ _  __ _  __   ____ _| |_   _  ___
##	  | |/ _` |/ _` | \ \ / / _` | | | | |/ _ \
##	  | | (_| | (_| |  \ V / (_| | | |_| |  __/
##	  |_|\__,_|\__, |   \_/ \__,_|_|\__,_|\___|
##	           |___/
##	
### Required  - tag 
### Instance Name 및 Tag "Name"는 별도 입력됨 => Name = "${var.network_node_name}-${var.instance_name}-${element(var.instance_index_az_01, count.index)}"
### 아래 ec2_instancs_tags에 "Name" tag는 추가할 필요 없음

variable "tag_Team"             { default = "Infra" }
variable "tag_User"             { default = "Infra" }
variable "tag_Role"             { default = "peer" }
variable "tag_Env"              { default = "Lisbon" }
variable "tag_Product"          { default = "goloop" }
variable "tag_Ec2schedulermsg"  { default = "" }
variable "tag_TargetGroups"     { default = "" }
variable "tag_OperatingSystem"  { default = "" }
variable "tag_Poc"              { default = "" }

locals {
  ec2_instance_tags = {
    Team            = var.tag_Team
    User            = var.tag_User
    Role            = var.tag_Role
    Env             = var.tag_Env
    Product         = var.tag_Product
    EC2SchedulerMSG = var.tag_Ec2schedulermsg
    _TargetGroups   = var.tag_TargetGroups
    OperatingSystem = var.tag_OperatingSystem
    Distribution    = "terraform"
#    Poc            = var.tag_Poc
  }
}


##	 ____ ____  _   _   _  __                      _
##	/ ___/ ___|| | | | | |/ /___ _   _ _ __   __ _(_)_ __
##	\___ \___ \| |_| | | ' // _ \ | | | '_ \ / _` | | '__|
##	 ___) |__) |  _  | | . \  __/ |_| | |_) | (_| | | |
##	|____/____/|_| |_| |_|\_\___|\__, | .__/ \__,_|_|_|
##	                             |___/|_|
#### Keypair .....................
variable "ec2_keypair_name" { default = "tbridge" }
###
#variable "ec2_keypair_pub_data" { default = "" }


##	  ____    ____        __  ______     ______    ___ ____
##	 / ___|  / /\ \      / / / ___\ \   / /  _ \  |_ _|  _ \
##	| |  _  / /  \ \ /\ / /  \___ \\ \ / /| |_) |  | || |_) |
##	| |_| |/ /    \ V  V /    ___) |\ V / |  _ <   | ||  __/
##	 \____/_/      \_/\_/    |____/  \_/  |_| \_\ |___|_|
##	
### Default tbridge gateway server ip
variable "GW_01_SVR_ADDR" 	    { default = "172.31.15.241/32" } ### DGW01
variable "GW_02_SVR_ADDR" 	    { default = "172.31.25.62/32" }  ### DGW02
variable "GW_01_SVR_PUB_ADDR" 	{ default = "13.209.180.15/32" } ### DGW01
variable "GW_02_SVR_PUB_ADDR" 	{ default = "52.79.36.251/32" }  ### DGW02

variable "TGW_01_SVR_ADDR"      { default = "172.31.20.246/32" } ### T-GW01
variable "TGW_02_SVR_ADDR"      { default = "172.31.23.163/32" } ### T-GW02
variable "TGW_01_SVR_PUB_ADDR"  { default = "13.124.36.111/32" } ### T-GW01
variable "TGW_02_SVR_PUB_ADDR"  { default = "13.209.140.46/32" } ### T-GW02



###	  __                  _   _               _                 _
###	 / _|_   _ _ __   ___| |_(_) ___  _ __   | | ___   ___ __ _| |___
###	| |_| | | | '_ \ / __| __| |/ _ \| '_ \  | |/ _ \ / __/ _` | / __|
###	|  _| |_| | | | | (__| |_| | (_) | | | | | | (_) | (_| (_| | \__ \
###	|_|  \__,_|_| |_|\___|\__|_|\___/|_| |_| |_|\___/ \___\__,_|_|___/
###	

locals {
  instance_sg_lists = [
     var.module_sg_ssh,
     var.module_sg_websoket,
     var.module_sg_alb,
     var.module_sg_ngrinder,
     var.module_sg_websoket_9900,
     var.module_sg_websoket_9999,
     var.module_sg_websoket_8081_8090
  ]
}



##	
##	__   ____   ____   ____   ____   ____   ____   ____   ____   __
##	\ \ / /\ \ / /\ \ / /\ \ / /\ \ / /\ \ / /\ \ / /\ \ / /\ \ / /
##	 \ V /  \ V /  \ V /  \ V /  \ V /  \ V /  \ V /  \ V /  \ V /
##	  \_/    \_/    \_/    \_/    \_/    \_/    \_/    \_/    \_/
##	
## 필요시 아래 config 수정





###############################################################
##+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#### IGW ( Internet Gateway)
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

variable "igw_routing_table_name" { default = "igw-rt" }

###############################################################
##+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#### Security group 
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### 아이콘루프 퍼블릭 ADDRESS - SKT 회선
variable "IL_PUB_ADDR_SKT" { default = "58.234.156.141/32" }
variable "IL_VPN_ADDR_SKT" { default = "58.234.156.144/32" }
variable "IL_LAN_ADDR_SKT" { default = "58.234.156.140/32" } ## LAN (Vmware)

### 아이콘루프 퍼블릭 ADDRESS - KT 회선
variable "IL_PUB_ADDR_KT" { default = "121.128.68.241/32" }
variable "IL_VPN_ADDR_KT" { default = "121.128.68.245/32" }
variable "IL_LAN_ADDR_KT" { default = "121.128.68.240/32" } ## LAN (Vmware)
## <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


#### Security groups variable
variable "sg_name" 			{ default = "sg-01" }

### Load balncer SG 
variable "sg_alb_name" 			{ default = "sg-alb-01" }

#### Loadbalancer variable
variable "lb_alb_name"			{ default = "alb-01" }
variable "lb_tg_port" 			{ default = "9000" }
variable "tg_healthcheck_protocol"  	{ default = "http" }

### Target group 
variable "lb_alb_tg_name" 		{ default = "alb-tg-01" }

### route53
variable "dns_zone_name" 		{ default = "net.solidwallet.io" }
locals {
  route53_recode_name = "${var.network_node_name}.${var.dns_zone_name}"
}

### Certification variable
variable "cert_domain_name" 	{ default = "*.net.solidwallet.io" } ### modify
variable "cert_tag_name" 		{ default = "terraform_init_cert" }     ### modify

variable "lb_ssl_policy_name"	{ default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06" }


variable "region_names" {
  description = "Default "
  type        = map(any)
  default = {
    "us-west-1" = {
      ### Califonia region
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
      ### mumbai region
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

locals {
  ###  type ==>>   1 : test / 2 : Develop / 3 : real
  region_name_rule = var.deploy_type == "1" ? var.region_names[var.aws_region]["test_name_rule"] : var.deploy_type == "2" ? var.region_names[var.aws_region]["dev_name_rule"] : var.deploy_type == "1" ? var.region_names[var.aws_region]["real_name_rule"] : ""

}

########################################################################
#    EC2 Instance config 
#
########################################################################

################################################################################
#######  GET AMI  variable config 

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

### Intance default user name centos, ec2-user ....
variable "remote_user" { default = "ec2-user" }

########### Instance Private IP setting  address

variable "start_private_ip" { default = ["11","11"] }
variable "set_hostname" 	{ default = "" }

### get network module 
variable "module_subnet_id" 	          { default = ["0","1"] }
variable "module_subnet_cidr" 	          { default = ["",""] }

variable "module_sg_ssh"                  { default = "" }
variable "module_sg_websocket"            { default = "" }
variable "module_sg_alb"                  { default = "" }
variable "module_sg_ngrinder"             { default = "" }
variable "module_eip_ips"                 { default = "" }

variable "module_sg_websocket_9900"       { default = "" }
variable "module_sg_websocket_9999"       { default = "" }
variable "module_sg_websocket_8081_8090"  { default = "" }

variable "module_instance_ids"            { default = "" }
