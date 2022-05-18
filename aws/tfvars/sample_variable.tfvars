# common variables
aws_region="ap-northeast-1"
network_node_name="TerraformNet" ### modify
instance_name="peer"         ### modify
ctz_instance_name="ctz"
last_instance_name="trk"

###  Test(1) , Develop(2), Real(3)
deploy_type="1" ### type 1:test, 2:develop, 3:real

# VPC variables
## vpc.tf
vpc_create_flag="0"
vpc_name="goloop-poc-jp-vpc"
vpc_net_addr="10.232.0.0/16"      ### modify

### subnet.tf
get_subnet_name_01="goloop-poc-jp-10.60.0.0/24" ### modify
get_subnet_name_02="goloop-poc-jp-10.60.1.0/24" ### modify
post_subnet_01_cidr_addr="10.232.100.0/24" ### modify
post_subnet_02_cidr_addr="10.232.200.0/24" ### modify

### igw.tf
igw_name="igw" ### modify

### routing_table.tf
igw_routing_table_name="igw-rt"

### Security Group / sg.tf
sg_name="sg-01"

AddTo_TGW_ADDR_flag=0
TGW_01_SVR_ADDR="172.31.20.246/32"     ### T-GW01
TGW_02_SVR_ADDR="172.31.23.163/32"     ### T-GW02
TGW_01_SVR_PUB_ADDR="13.124.36.111/32"     ### T-GW01
TGW_02_SVR_PUB_ADDR="13.209.140.46/32"     ### T-GW02


#==================================================================================================
## load-balancer variables

### Application LoadBalancer
alb_set_flag=0
alb_name="alb-01"
alb_ssl_policy_name="ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
alb_tg_name="alb-tg-01"
alb_tg_port=9000
alb_health_check_path="/"
alb_hc_interval=10
alb_hc_threshold=3
alb_unhc_threshold=2

### Certification variable
cert_domain_name="*.net.solidwallet.io" ### modify
cert_tag_name="terraform_init_cert"  ### modify


#========================================================================================================
## EC2 instances

create_instance_count="0"
#aws_instance_type="c5.2xlarge"
aws_instance_type="c5.2xlarge"
ctz_node_count=0

last_instance_set_flag=0
create_ctz_set_flag=0

root_vol_type="gp3"
root_vol_size="20"
root_vol_iops="3000"
root_vol_throughput="125"

ebs_blockdevice_set_flag="false"
ebs_vol_type="gp3"
ebs_vol_size="20"
ebs_vol_iops="3000"
ebs_vol_throughput="125"

ec2_keypair_name="tbridge"

tag_Team="Infra"
tag_User="Infra"
tag_Role="peer"
tag_Env="TerraformTest"
tag_Product="Test"

ami_name="self_amazon_linux"

### AMI owner
aws_ami_owner="229930918337"

###  IAM  ROLE NAME
iam_role_name="EC2RoleForSSM"

### print flag
show_Network_00_VPC_04_Subnet="true"