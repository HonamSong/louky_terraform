#### Terraform v0.14.7
#### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table


#####  VPC생성 시 자동으로 생성된 routing table을 관리하기 위한 설정 
resource "aws_default_route_table" "modifi_routing_table_tagname" {
  count 			= var.vpc_create_flag == "1" ? "1" : "0"
  default_route_table_id	= aws_vpc.create_vpc[count.index].default_route_table_id

  tags = {
    Name = "${local.region_name_rule}-${var.network_node_name}-routing-${var.aws_vpc_net_addr}"
  }
}


### Internet gateway routing table
resource "aws_route_table" "igw_routing_table" {
  count 		= var.vpc_create_flag == "1" ? "1" : "0"
  #vpc_id		= aws_internet_gateway.igw.id
  vpc_id		= aws_vpc.create_vpc[count.index].id

  route {
    cidr_block		= "0.0.0.0/0"
    gateway_id		= aws_internet_gateway.create_igw[count.index].id
  }

  tags = {
    Name = "${local.region_name_rule}-${var.network_node_name}-${var.igw_routing_table_name}"
  }
}


#### IGW routing table add to Subnet address
#### Association route
resource "aws_route_table_association" "AddToSUBNET_a" {
  count 		= var.vpc_create_flag == "1" ? "1" : "0"
  subnet_id      	= aws_subnet.create_subnet_01[count.index].id
  route_table_id 	= aws_route_table.igw_routing_table[count.index].id
}
resource "aws_route_table_association" "AddToSUBNET_b" {
  count 		= var.vpc_create_flag == "1" ? "1" : "0"
  subnet_id      	= aws_subnet.create_subnet_02[count.index].id
  route_table_id 	= aws_route_table.igw_routing_table[count.index].id
}
