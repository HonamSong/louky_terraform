# vpc - igw.tf

#### Internet gateway ==>	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway

data "aws_internet_gateway" "get_igw" {
  count = var.vpc_create_flag == "0" ? "1" : "0"
  filter {
	name   = "attachment.vpc-id"
	values = [data.aws_vpc.get_vpc[count.index].id]
  }
}

#### Internet gateway ==>	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "post_igw" {
  count 		= var.vpc_create_flag == "1" ? "1" : "0"
  vpc_id		= aws_vpc.post_vpc[count.index].id

  tags = {
	#Name		= var.igw_tag_name
	#Name		= "${local.region_name_rule}-${var.network_node_name}-${var.igw_name}-${count.index + 1}"
	Name		= "${local.igw_tag_name}-${count.index + 1}"
  }
}

output "igw_info" {
  value = var.vpc_create_flag == "0" ? data.aws_internet_gateway.get_igw[0].* : aws_internet_gateway.post_igw[0].*
}
