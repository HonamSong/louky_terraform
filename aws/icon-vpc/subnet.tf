# vpc - subnet.tf

locals {
  subnet_01_name = "${local.region_name_rule}-${var.network_node_name}-subnet-${var.post_subnet_01_cidr_addr}"
  subnet_02_name = "${local.region_name_rule}-${var.network_node_name}-subnet-${var.post_subnet_02_cidr_addr}"

  availability_zone_01 = var.region_names[var.aws_region]["az_01"]
  availability_zone_02 = var.region_names[var.aws_region]["az_02"]
}

data "aws_subnet" "get_subnet" {
  count = var.vpc_create_flag == "0" ? 2 : 0
  availability_zone =  count.index == 0 ? local.availability_zone_01 : local.availability_zone_02
  filter {
	name   = "tag:Name"
	values = count.index == 0 ? ["${var.get_subnet_name_01}*"] : ["${var.get_subnet_name_02}*"]
  }
  depends_on = [
	data.aws_vpc.get_vpc,
  ]
}

resource "aws_subnet" "post_subnet" {
  count             = var.vpc_create_flag == "1" ? 2 : 0
  vpc_id            = aws_vpc.post_vpc[0].id
  cidr_block		= count.index == 0 ? var.post_subnet_01_cidr_addr : var.post_subnet_02_cidr_addr
  availability_zone	= count.index == 0 ? local.availability_zone_01 : local.availability_zone_02

  tags = {
	Name		= count.index == 0 ? local.subnet_01_name : local.subnet_02_name
  }
  depends_on = [
	resource.aws_vpc.post_vpc,
  ]
}

#==========================================================
output "az_subnet" {
  value = var.vpc_create_flag == "1" ? aws_subnet.post_subnet[*] : data.aws_subnet.get_subnet[*]
  description = "The Availability Zone Subnet Information"
}