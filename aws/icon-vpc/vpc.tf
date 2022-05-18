###  VPC Create

resource "aws_vpc" "post_vpc" {
  count                = var.vpc_create_flag == "1" ? "1" : "0"
  cidr_block           = var.vpc_net_addr
  enable_dns_hostnames = true #DNS Hostname 사용 옵션, 기본은 false
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    ## ex)  hnsong_vpc-10.30.0.0/16
    #Name = "${local.region_name_rule}-${var.network_node_name}-vpc-${var.aws_vpc_net_addr}"
    Name = local.vpc_tag_name
  }
}

data "aws_vpc" "get_vpc" {
  count = var.vpc_create_flag == "0" ? "1" : "0"
  #id = "vpc-0e698854eb7d4f0e0"
  #id = "vpc-05fc492b400afb432"
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}*"]
  }
}

output "vpc_info" {
  value =  var.vpc_create_flag == "1" ? aws_vpc.post_vpc[0].* : data.aws_vpc.get_vpc[0].*
}