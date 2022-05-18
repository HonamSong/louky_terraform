# vpc - routing_table.tf

locals {
  igw_table_array_cnt = length(aws_route_table.AddToIGW[*].id) == 1 ? 0 : null
}

#####  VPC생성 시 자동으로 생성된 routing table을 관리하기 위한 설정
resource "aws_default_route_table" "modify_routing_table_tag_name" {
  count 			        = var.vpc_create_flag == "1" ? "1" : "0"
  default_route_table_id	= aws_vpc.post_vpc[count.index].default_route_table_id

  tags = {
	Name = "${local.default_rt_tag_name}"
  }
}


### Internet gateway routing table
resource "aws_route_table" "AddToIGW" {
  count 		= var.vpc_create_flag == "1" ? "1" : "0"
  vpc_id		= aws_vpc.post_vpc[count.index].id

  route {
	cidr_block		= "0.0.0.0/0"
	gateway_id		= aws_internet_gateway.post_igw[count.index].id
  }

  tags = {
	Name = "${local.rt_tag_name}"
  }
}


#### IGW routing table add to Subnet address
#### Association route
resource "aws_route_table_association" "AddToSUBNET" {
  count 		= var.vpc_create_flag == "1" ? "2" : "0"
  subnet_id      	= aws_subnet.post_subnet[count.index].id
  route_table_id 	= aws_route_table.AddToIGW[local.igw_table_array_cnt].id
  depends_on = [
	aws_route_table.AddToIGW,
  ]
}


output "default_routing_table_info" {
  value = var.vpc_create_flag == "1" ? aws_default_route_table.modify_routing_table_tag_name[0].* : null
}

output "routing_table_igw_info" {
  value = var.vpc_create_flag == "1" ? aws_route_table.AddToIGW[local.igw_table_array_cnt].* : null
}

output "add_routing_table_info" {
  value = var.vpc_create_flag == "1" ? aws_route_table_association.AddToSUBNET[*].* : null
}
