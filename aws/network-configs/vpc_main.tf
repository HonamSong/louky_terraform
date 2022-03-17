#### Terraform v0.14.7
####  VPC	==> 	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
####  SUBNET 	==>	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

### networking variable 
###################################################################
#####  GET VPC info 
data "aws_vpc" "get_vpc" {
  count = var.vpc_create_flag == "0" ? "1" : "0"
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}*"]
  }
}

data "aws_subnet" "get_subnet_01" {
  count = var.vpc_create_flag == "0" ? "1" : "0"
  #availability_zone = var.availability_zone_01
  availability_zone = var.region_names[var.aws_region]["az_01"]
  filter {
    name   = "tag:Name"
    values = ["${var.subnet_name_01}*"]
  }
}

data "aws_subnet" "get_subnet_02" {
  count = var.vpc_create_flag == "0" ? "1" : "0"
  #availability_zone = var.availability_zone_02
  availability_zone = var.region_names[var.aws_region]["az_02"]
  filter {
    name   = "tag:Name"
    values = ["${var.subnet_name_02}*"]
  }
}

#### Internet gateway ==>	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway

data "aws_internet_gateway" "get_igw" {
  count = var.vpc_create_flag == "0" ? "1" : "0"
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.get_vpc[count.index].id]
  }
}

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

###  VPC Create
resource "aws_vpc" "create_vpc" {
  count                 = var.vpc_create_flag == "1" ? "1" : "0"
  cidr_block            = var.aws_vpc_net_addr
  enable_dns_hostnames	= true        #DNS Hostname 사용 옵션, 기본은 false
  enable_dns_support	= true
  instance_tenancy      = "default"

  tags = {
    ## ex)  hnsong_vpc-10.30.0.0/16
    Name = "${local.region_name_rule}-${var.network_node_name}-vpc-${var.aws_vpc_net_addr}"
  }
}

resource "aws_subnet" "create_subnet_01" {
  count             = var.vpc_create_flag == "1" ? "1" : "0"
  vpc_id            = aws_vpc.create_vpc[count.index].id
  cidr_block		= var.subnet_01_cidr_addr
  #availability_zone	= var.availability_zone_01
  availability_zone	= var.region_names[var.aws_region]["az_01"]

  tags = {
    #Name 		= var.subnet_a_tag_name
    Name		= "${local.region_name_rule}-${var.network_node_name}-subnet-${var.subnet_01_cidr_addr}"
  }
}

resource "aws_subnet" "create_subnet_02" {
  count             = var.vpc_create_flag == "1" ? "1" : "0"
  vpc_id            = aws_vpc.create_vpc[count.index].id
  cidr_block		= var.subnet_02_cidr_addr
  #availability_zone	= var.availability_zone_02
  availability_zone = var.region_names[var.aws_region]["az_02"]

  tags = {
    #Name		= var.subnet_b_tag_name
    Name		= "${local.region_name_rule}-${var.network_node_name}-subnet-${var.subnet_02_cidr_addr}"
  }
}


#### Internet gateway ==>	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "create_igw" {
  count 		= var.vpc_create_flag == "1" ? "1" : "0"
  vpc_id		= aws_vpc.create_vpc[count.index].id

  tags = {
    #Name		= var.igw_tag_name
    Name		= "${local.region_name_rule}-${var.network_node_name}-${var.igw_name}-${count.index + 1}"
  }
}

