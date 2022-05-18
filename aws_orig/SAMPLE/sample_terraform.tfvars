###
#
##       ____  _____ ____ ___ ___  _   _   _   _    _    __  __ _____
##      |  _ \| ____/ ___|_ _/ _ \| \ | | | \ | |  / \  |  \/  | ____|
##      | |_) |  _|| |  _ | | | | |  \| | |  \| | / _ \ | |\/| |  _|
##      |  _ <| |__| |_| || | |_| | |\  | | |\  |/ ___ \| |  | | |___
##      |_| \_\_____\____|___\___/|_| \_| |_| \_/_/   \_\_|  |_|_____|
##
### AWS Region
#aws_region="us-west-1" 
aws_region="ap-northeast-2" 


# ___             _                         _   _
#|_ _|_ __   __ _| |_ __ _ _ __   ___ ___  | \ | | __ _ _ __ ___   ___
# | || '_ \ / _` | __/ _` | '_ \ / __/ _ \ |  \| |/ _` | '_ ` _ \ / _ \
# | || | | | (_| | || (_| | | | | (_|  __/ | |\  | (_| | | | | | |  __/
#|___|_| |_|\__,_|\__\__,_|_| |_|\___\___| |_| \_|\__,_|_| |_| |_|\___|
##Instance name  => ${local.region_name_rule}-${var.network_node_name}-${var.instance_name}-${element(var.instance_index_az_01, count.index)}
##  ex) variable "network_node_name"    { default = "terraform-net"}            ### modify
##  ex) variable "instance_name"        { default = "peer" }                    ### modify
##  ex) result >>>  acat-terraform-net-peer-01

network_node_name="TESTNET"                   ### modify
instance_name="peer"              	        ### modify
last_instance_name="trkadmin"



##        ___  _   _      __   ___  _____ _____   _____ _        _    ____
##       / _ \| \ | |    / /  / _ \|  ___|  ___| |  ___| |      / \  / ___|
##      | | | |  \| |   / /  | | | | |_  | |_    | |_  | |     / _ \| |  _
##      | |_| | |\  |  / /   | |_| |  _| |  _|   |  _| | |___ / ___ \ |_| |
##       \___/|_| \_| /_/     \___/|_|   |_|     |_|   |_____/_/   \_\____|
###  On/OFF flag

 #+++  VPC create flag
vpc_create_flag="0"       #### 0  => Not create   , 1 => create

# +++  Load Balncer create flag
lb_set_flag="1"       #### 0  => disable(off) , 1 => enable(on)

# ---  Load balancer health Check path
#health_check_path="/api/v3"       ### modify
health_check_path="/admin/chain"       ### modify
lb_tg_port="9900"
tg_healthcheck_protocol="http"

# +++  Instance Private IP setting On/Off flag
pri_ip_set_flag="1"       #### 0 => disable(off)  , 1 => enable(on)

# +++  Route53 Set On/Off flag
route53_set_flag="1"       #### 0 => disable(off)  , 1 => enable(on)

# +++ other node setting flag of the last instance
last_instance_set_flag="0"



##      __     ______   ____
##      \ \   / /  _ \ / ___|
##       \ \ / /| |_) | |
##        \ V / |  __/| |___
##         \_/  |_|    \____|
##################################################
### VPC Not Create variables
### Example
##  Ex) vpc_name="goloop-poc-*"				### modify
##  Ex) subnet_name_01="goloop-poc-*-10.*.8"		### modify
##  Ex) subnet_name_02="goloop-poc-*-10.*.9"		### modify

vpc_name="{{VPC_NAME}}"				### modify
subnet_name_01="{{SUBNET_NAME_AZ_01"		### modify
subnet_name_02="{{SUBNET_NAME_AZ_02"		### modify

#### +++++++++++++++++++++++++++++++++++++++++++++++++++
####  VPC  Create variables
aws_vpc_net_addr="10.232.0.0/16"    ### modify
subnet_01_cidr_addr="10.232.100.0/24"  ### modify
subnet_02_cidr_addr="10.232.200.0/24"  ### modify

igw_name="igw"              ### modify


#       ___ _   _ ____ _____  _    _   _  ____ _____
##      |_ _| \ | / ___|_   _|/ \  | \ | |/ ___| ____|
##       | ||  \| \___ \ | | / _ \ |  \| | |   |  _|
##       | || |\  |___) || |/ ___ \| |\  | |___| |___
##      |___|_| \_|____/ |_/_/   \_\_| \_|\____|_____|

##### Create Ec2 instance count
create_instance_count="5"		#### 

####  Instance static private ip Setting field
start_private_ip=["11","11"]


### EC2 Instance deploy Type
###  Test(1) , Develop(2), Real(3)
deploy_type="1" 		 ### type 1 : test, 2 : develop, 3 : real

## ECE Instance type
###  c5.xlarge, c5.2xlarge, c5.4xlarge
aws_instance_type="t3.medium"

## root device default  volume type  - gp2, gp3  ....
instance_root_vol_type="gp3"

## root device default size (GB)
instance_root_vol_size="30"              ### modify

root_vol_iops="256"


###  IAM  ROLE NAME
iam_role_name="EC2RoleForSSM"


##       _____                        _
##      |_   _|_ _  __ _  __   ____ _| |_   _  ___
##        | |/ _` |/ _` | \ \ / / _` | | | | |/ _ \
##        | | (_| | (_| |  \ V / (_| | | |_| |  __/
##        |_|\__,_|\__, |   \_/ \__,_|_|\__,_|\___|
##                 |___/
##
### Required  - tag
### Instance Name 및 Tag "Name"는 별도 입력됨 => Name = "${var.network_node_name}-${var.instance_name}-${element(var.instance_index_az_01, count.index)}"
### 아래 ec2_instancs_tags에 "Name" tag는 추가할 필요 없음

####  INSTANCE의  TAG 설정은  variables.tf 에서  수정 
tag_Team="Infra"
tag_User="Infra"
tag_Role="peer"
tag_Env="{{TESTNET}}"
tag_Poc="goloop-poc"
tag_Product="Loopchain"





##       ____ ____  _   _   _  __                      _
##      / ___/ ___|| | | | | |/ /___ _   _ _ __   __ _(_)_ __
##      \___ \___ \| |_| | | ' // _ \ | | | '_ \ / _` | | '__|
##       ___) |__) |  _  | | . \  __/ |_| | |_) | (_| | | |
##      |____/____/|_| |_| |_|\_\___|\__, | .__/ \__,_|_|_|
##                                   |___/|_|
#### Keypair .....................
ec2_keypair_name="tbridge"



##        ____    ____        __  ______     ______    ___ ____
##       / ___|  / /\ \      / / / ___\ \   / /  _ \  |_ _|  _ \
##      | |  _  / /  \ \ /\ / /  \___ \\ \ / /| |_) |  | || |_) |
##      | |_| |/ /    \ V  V /    ___) |\ V / |  _ <   | ||  __/
##       \____/_/      \_/\_/    |____/  \_/  |_| \_\ |___|_|
##
### Default tbridge gateway server ip
GW_01_SVR_ADDR="172.31.15.241/32"  	### DGW01
GW_02_SVR_ADDR="172.31.25.62/32" 	### DGW02
GW_01_SVR_PUB_ADDR="13.209.180.15/32"	### DGW01
GW_02_SVR_PUB_ADDR="52.79.36.251/32"	### DGW02




cert_domain_name="*.net.solidwallet.io"



