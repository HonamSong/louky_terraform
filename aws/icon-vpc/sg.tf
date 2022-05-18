# vpc - sg.tf
### set security group

locals {
  subnet_cidr_01 = var.vpc_create_flag == "0" ? data.aws_subnet.get_subnet[0].cidr_block : aws_subnet.post_subnet[0].cidr_block
  subnet_cidr_02 = var.vpc_create_flag == "0" ? data.aws_subnet.get_subnet[1].cidr_block : aws_subnet.post_subnet[1].cidr_block

  # concat = list를 병합 할때 사용 (list merge)
  IL_SKT_LINE    = [ var.IL_PUB_ADDR_SKT, var.IL_VPN_ADDR_SKT, var.IL_LAN_ADDR_SKT ]
  IL_KT_LINE     = [ var.IL_PUB_ADDR_KT, var.IL_VPN_ADDR_KT, var.IL_LAN_ADDR_KT ]
  IL_ADDR_ALL    = concat(local.IL_SKT_LINE, local.IL_KT_LINE)

  DGW_SVR_ADDR   = [ var.DGW_01_SVR_ADDR, var.DGW_02_SVR_ADDR, var.DGW_01_SVR_PUB_ADDR, var.DGW_02_SVR_PUB_ADDR ]
  TGW_SVR_ADDR   = [ var.TGW_01_SVR_ADDR, var.TGW_02_SVR_ADDR, var.TGW_01_SVR_PUB_ADDR, var.TGW_02_SVR_PUB_ADDR ]
  GW_SVR_ADDR    = var.AddTo_TGW_ADDR_flag == 1 ? concat(local.DGW_SVR_ADDR, local.TGW_SVR_ADDR) : local.DGW_SVR_ADDR

  VPC_ID         = var.vpc_create_flag == "1" ? aws_vpc.post_vpc[0].id : data.aws_vpc.get_vpc[0].id
  VPC_CIDR_BLOCK = var.vpc_create_flag == "1" ? [ aws_vpc.post_vpc[0].cidr_block ]:[ data.aws_vpc.get_vpc[0].cidr_block ]

  NetALL_CIDR = "0.0.0.0/0"
}

###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#### Prep node SG
resource "aws_security_group" "post_sg_ssh_port" {
  name			= "${local.sg_tag_name}_ssh"
  description	= "${local.sg_tag_name}_ssh"
  vpc_id		= local.VPC_ID

  tags = {
	Name = "${local.sg_tag_name}_ssh"
  }

  ingress {
	protocol		= "tcp"
	from_port		= 22
	to_port         = 22
	cidr_blocks		= local.IL_ADDR_ALL
	description		= "IL SKT/KT LINE"
  }

  ingress {
	protocol        = "tcp"
	from_port       = 22
	to_port         = 22
	cidr_blocks     = local.GW_SVR_ADDR
	description     = "Gateway Server SSH "
  }

  ingress {
	protocol        = "tcp"
	from_port       = 22
	to_port         = 22
	cidr_blocks     = [ local.subnet_cidr_01, local.subnet_cidr_02 ]
	description     = "AWS Availability ZONE SSH "
  }

  egress {
	protocol		= "-1"
	from_port		= 0
	to_port         = 0
	cidr_blocks		= [ local.NetALL_CIDR ]
  }
}

#### ALB SG
resource "aws_security_group" "post_sg_alb_port" {
  name			= "${local.sg_tag_name}_alb"
  description	= "${local.sg_tag_name}_alb"
  vpc_id		=  local.VPC_ID

  tags = {
	Name		= "${local.sg_tag_name}_alb"
  }

  ingress {
	protocol		= "tcp"
	from_port		= 80
	to_port		    = 80
	cidr_blocks		= [ local.NetALL_CIDR ]
	description		= "HTTP"
  }

  ingress {
	protocol		= "tcp"
	from_port		= 443
	to_port		    = 443
	cidr_blocks		= [ local.NetALL_CIDR ]
	description		= "HTTPS"
  }

  egress {
	protocol		= "-1"
	from_port		= 0
	to_port		    = 0
	cidr_blocks		= [ local.NetALL_CIDR ]
  }
}

resource "aws_security_group" "post_sg_websocket" {
  name			= "${local.sg_tag_name}_websoket"
  description	= "${local.sg_tag_name}_websoket"
  vpc_id		= local.VPC_ID

  tags = {
	Name		= "${local.sg_tag_name}_websoket"
  }

  ingress {
	protocol		= "tcp"
	from_port		= 80
	to_port		    = 80
	cidr_blocks		= local.VPC_CIDR_BLOCK
	description		= "HTTP"
  }

  ingress {
	protocol		= "tcp"
	from_port		= 443
	to_port		    = 443
	cidr_blocks		= local.VPC_CIDR_BLOCK
	description		= "HTTPS"
  }

  ingress {
	protocol		= "tcp"
	from_port		= 7100
	to_port		    = 7100
	cidr_blocks		= [ local.NetALL_CIDR ]
	description		= "Node Web socket 7100 - Net All"
  }

  ingress {
	protocol        = "tcp"
	from_port       = 8081
	to_port         = 8090
	cidr_blocks     = [ local.subnet_cidr_01, local.subnet_cidr_02 ]
	description     = "AWS Availability ZONE CIDR - 8081-8090"
  }

  ingress {
	protocol        = "tcp"
	from_port       = 8081
	to_port         = 8090
	cidr_blocks     = local.IL_ADDR_ALL
	description     = "Extra/ICON SKT/KT LINE - 8081-8090"
  }

  ingress {
	protocol        = "tcp"
	from_port       = 8081
	to_port         = 8090
	cidr_blocks     = local.GW_SVR_ADDR
	description     = "Extra/Gateway Server - 8081-8090"
  }

  ingress {
	protocol        = "tcp"
	from_port       = 8081
	to_port         = 8090
	cidr_blocks     = local.VPC_CIDR_BLOCK
	description     = "Extra/Peer EIP - 8081-8090"
  }

  ingress {
	protocol		= "tcp"
	from_port		= 8800
	to_port		    = 8800
	cidr_blocks		= local.IL_ADDR_ALL
	description		= "JMON - SKT/KT Line - 8800"
  }

  ingress {
	protocol        = "tcp"
	from_port       = 8800
	to_port         = 8800
	cidr_blocks     = [ local.subnet_cidr_01, local.subnet_cidr_02 ]
	description     = "AWS Availability ZONE - CIDR - 8800"
  }

  ingress {
	protocol		= "tcp"
	from_port		= 9000
	to_port		    = 9000
	cidr_blocks		= [ local.NetALL_CIDR ]
	description		= "Node Web socket 9000 - Net All"
  }

  ingress {
	protocol        = "tcp"
	from_port       = 9900
	to_port         = 9900
	cidr_blocks     = [ local.subnet_cidr_01, local.subnet_cidr_02 ]
	description     = "AWS Availability ZONE - CIDR - 9900"
  }

  ingress {
	protocol        = "tcp"
	from_port       = 9900
	to_port         = 9900
	cidr_blocks     = local.IL_ADDR_ALL
	description     = "PROXY/ICON SKT/KT LINE - 9900"
  }

  ingress {
	protocol        = "tcp"
	from_port       = 9900
	to_port         = 9900
	cidr_blocks     = local.GW_SVR_ADDR
	description     = "PROXY/Gateway Server - 9900"
  }

  ingress {
	protocol        = "tcp"
	from_port       = 9999
	to_port         = 9999
	cidr_blocks     = [ local.subnet_cidr_01, local.subnet_cidr_02 ]
	description     = "Goloop-control/AWS Availability ZONE - CIDR - 9999"
  }

  ingress {
	protocol        = "tcp"
	from_port       = 9999
	to_port         = 9999
	cidr_blocks     = local.IL_ADDR_ALL
	description     = "Goloop-control/IL SKT/KT LINE - 9999"
  }

  ingress {
	protocol        = "tcp"
	from_port       = 9999
	to_port         = 9999
	cidr_blocks     = local.GW_SVR_ADDR
	description     = "Goloop-control/Gateway Server - 9999"
  }


  egress {
	protocol		= "-1"
	from_port		= 0
	to_port		    = 0
	cidr_blocks		= [ local.NetALL_CIDR ]
  }
}

resource "aws_security_group" "post_sg_ngrinder_port" {
  name		  	    = "${local.sg_tag_name}_ngrinder"
  description  	    = "${local.sg_tag_name}_ngrinder"
  vpc_id	  	    = local.VPC_ID

  tags = {
	Name	  	    = "${local.sg_tag_name}_ngrinder"
  }

  ingress {
	protocol        = "tcp"
	from_port       = 12000
	to_port         = 12009
	cidr_blocks     = local.VPC_CIDR_BLOCK
	description     = "ngrinder - 12000-12009"
  }

  ingress {
	protocol        = "tcp"
	from_port       = 16001
	to_port         = 16001
	cidr_blocks     = local.VPC_CIDR_BLOCK
	description     = "ngrinder - 16001"
  }

  egress {
	protocol		= "-1"
	from_port		= 0
	to_port		    = 0
	cidr_blocks		= ["0.0.0.0/0"]
  }
}


output "sg_ssh" {
  value = aws_security_group.post_sg_ssh_port.*
}

output "sg_alb" {
  value = aws_security_group.post_sg_alb_port.*
}

output "sg_websocket" {
  value = aws_security_group.post_sg_websocket.*
}

output "sg_ngrinder" {
  value = aws_security_group.post_sg_ngrinder_port.*
}
