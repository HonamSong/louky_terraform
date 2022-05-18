#### Terraform v0.14.7
### set security group 

locals {
  subnet_cidr_01 = var.vpc_create_flag == "0" ? data.aws_subnet.get_subnet_01[0].cidr_block : aws_subnet.create_subnet_01[0].cidr_block
  subnet_cidr_02 = var.vpc_create_flag == "0" ? data.aws_subnet.get_subnet_02[0].cidr_block : aws_subnet.create_subnet_02[0].cidr_block
}

###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#### Prep node SG
resource "aws_security_group" "create_sg_ssh_connection" {
  count 		= var.vpc_create_flag == "0" ? "1" : "1"
  name			= "${var.network_node_name}_${var.sg_name}_ssh"
  description	= "${var.network_node_name}_${var.sg_name}_ssh"
  vpc_id		= var.vpc_create_flag == "1" ? aws_vpc.create_vpc[count.index].id : data.aws_vpc.get_vpc[count.index].id

  tags = {
    Name = "${var.network_node_name}_${var.sg_name}_ssh"
  }

  ingress {
    protocol		= "tcp"
    from_port		= 22
    to_port         = 22
    cidr_blocks		= [ var.IL_PUB_ADDR_SKT, var.IL_VPN_ADDR_SKT, var.IL_LAN_ADDR_SKT ]
    description		= "IL SKT LINE"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    cidr_blocks     = [ var.IL_PUB_ADDR_KT, var.IL_VPN_ADDR_KT, var.IL_LAN_ADDR_KT ]
    description     = "IL KT LINE"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    cidr_blocks     = [ var.GW_01_SVR_ADDR, var.GW_02_SVR_ADDR, var.GW_01_SVR_PUB_ADDR, var.GW_02_SVR_PUB_ADDR ]
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
    cidr_blocks		= ["0.0.0.0/0"]
  }
}

#### ALB SG
resource "aws_security_group" "create_sg_alb" {
  count         = var.vpc_create_flag == "0" ? "1" : "1"
  name			= "${var.network_node_name}_${var.sg_name}_alb"
  description	= "${var.network_node_name}_${var.sg_name}_alb"
  vpc_id		=  var.vpc_create_flag == "1" ? aws_vpc.create_vpc[count.index].id : data.aws_vpc.get_vpc[count.index].id

  tags = {
    Name		= "${var.network_node_name}_${var.sg_name}_alb"
  }

  ingress {
    protocol		= "tcp"
    from_port		= 80
    to_port		    = 80
    cidr_blocks		= [ "0.0.0.0/0" ] 
    description		= "HTTP"
  }

  ingress {
    protocol		= "tcp"
    from_port		= 443
    to_port		    = 443
    cidr_blocks		= [ "0.0.0.0/0" ] 
    description		= "HTTPS"
  }

  egress {
    protocol		= "-1"
    from_port		= 0
    to_port		    = 0
    cidr_blocks		= ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "create_sg_websocket" {
  count         = var.vpc_create_flag == "0" ? "1" : "1"
  name			= "${var.network_node_name}_${var.sg_name}_websoket"
  description	= "${var.network_node_name}_${var.sg_name}_websoket"
  vpc_id		= var.vpc_create_flag == "1" ? aws_vpc.create_vpc[count.index].id : data.aws_vpc.get_vpc[count.index].id

  tags = {
    Name		= "${var.network_node_name}_${var.sg_name}_websoket"
  }

  ingress {
    protocol		= "tcp"
    from_port		= 80
    to_port		    = 80
    cidr_blocks		= var.vpc_create_flag == "1" ? [ aws_vpc.create_vpc[count.index].cidr_block ]:[ data.aws_vpc.get_vpc[count.index].cidr_block ]
    description		= "HTTP"
  }

  ingress {
    protocol		= "tcp"
    from_port		= 443
    to_port		    = 443
    #cidr_blocks	= var.vpc_create_flag == "1" ? [ aws_vpc.create_vpc.*.cidr_block ]:[ data.aws_vpc.get_vpc.*.cidr_block ]
    cidr_blocks		= var.vpc_create_flag == "1" ? [ aws_vpc.create_vpc[count.index].cidr_block ]:[ data.aws_vpc.get_vpc[count.index].cidr_block ]
    description		= "HTTPS"
  }

  ingress {
    protocol		= "tcp"
    from_port		= 8800
    to_port		    = 8800
    cidr_blocks		= [ var.IL_PUB_ADDR_KT, var.IL_VPN_ADDR_KT, var.IL_LAN_ADDR_KT ]
    description		= "JMON - KT Line"
  }

  ingress {
    protocol		= "tcp"
    from_port		= 8800
    to_port		    = 8800
    cidr_blocks		= [ var.IL_PUB_ADDR_SKT, var.IL_VPN_ADDR_SKT, var.IL_LAN_ADDR_SKT ]
    description		= "JMON - SKT Line"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 8800
    to_port         = 8800
    cidr_blocks     = [ local.subnet_cidr_01, local.subnet_cidr_02 ]
    description     = "AWS Availability ZONE - CIDR "
  }

  ingress {
    protocol		= "tcp"
    from_port		= 7100
    to_port		    = 7100
    cidr_blocks		= [ "0.0.0.0/0" ]
    description		= "Node Web socket 7100 - Net All"
  }

  ingress {
    protocol		= "tcp"
    from_port		= 9000
    to_port		    = 9000
    cidr_blocks		= [ "0.0.0.0/0" ]
    description		= "Node Web socket 9000 - Net All"
  }

  egress {
    protocol		= "-1"
    from_port		= 0
    to_port		    = 0
    cidr_blocks		= ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "create_sg_websocket_9900" {
  count         = var.vpc_create_flag == "0" ? "1" : "1"
  name          = "${var.network_node_name}_${var.sg_name}_websoket_9900"
  description   = "${var.network_node_name}_${var.sg_name}_websoket_9900"
  vpc_id		= var.vpc_create_flag == "1" ? aws_vpc.create_vpc[count.index].id : data.aws_vpc.get_vpc[count.index].id

  tags = {
    Name		= "${var.network_node_name}_${var.sg_name}_websoket_9900"
  }

  ingress {
    protocol            = "tcp"
    from_port           = 9900
    to_port             = 9900
    cidr_blocks         = [ local.subnet_cidr_01, local.subnet_cidr_02 ]
    description         = "AWS Availability ZONE - CIDR"
  }

  ingress {
    protocol            = "tcp"
    from_port           = 9900
    to_port             = 9900
    cidr_blocks         = [ var.IL_PUB_ADDR_SKT, var.IL_VPN_ADDR_SKT, var.IL_LAN_ADDR_SKT ]
    description         = "PROXY/ICON SKT LINE"
  }

  ingress {
    protocol            = "tcp"
    from_port           = 9900
    to_port             = 9900
    cidr_blocks         = [ var.IL_PUB_ADDR_KT, var.IL_VPN_ADDR_KT, var.IL_LAN_ADDR_KT ]
    description         = "PROXY/ICON KT Line"
  }

  ingress {
    protocol            = "tcp"
    from_port           = 9900
    to_port             = 9900
    cidr_blocks         = [ var.GW_01_SVR_ADDR, var.GW_02_SVR_ADDR, var.GW_01_SVR_PUB_ADDR, var.GW_02_SVR_PUB_ADDR ]
    description         = "PROXY/Gateway Server"
  }


  egress {
    protocol		= "-1"
    from_port		= 0
    to_port         = 0
    cidr_blocks		= ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "create_sg_websocket_8081_8090" {
  count         = var.vpc_create_flag == "0" ? "1" : "1"
  name			= "${var.network_node_name}_${var.sg_name}_websoket_8081_8090"
  description   = "${var.network_node_name}_${var.sg_name}_websoket_8081_8090"
  vpc_id		= var.vpc_create_flag == "1" ? aws_vpc.create_vpc[count.index].id : data.aws_vpc.get_vpc[count.index].id

  tags = {
    Name		= "${var.network_node_name}_${var.sg_name}_websoket_8081_8090"
  }

  ingress {
    protocol            = "tcp"
    from_port           = 8081
    to_port             = 8090
    cidr_blocks         = [ local.subnet_cidr_01, local.subnet_cidr_02 ]
    description         = "AWS Availability ZONE CIDR"
  }

  ingress {
    protocol            = "tcp"
    from_port           = 8081
    to_port             = 8090
    cidr_blocks         = [ var.IL_PUB_ADDR_SKT, var.IL_VPN_ADDR_SKT, var.IL_LAN_ADDR_SKT ]
    description         = "Extra/ICON SKT LINE"
  }

  ingress {
    protocol            = "tcp"
    from_port           = 8081
    to_port             = 8090
    cidr_blocks         = [ var.IL_PUB_ADDR_KT, var.IL_VPN_ADDR_KT, var.IL_LAN_ADDR_KT ]
    description         = "Extra/ICON KT Line"
  }

  ingress {
    protocol            = "tcp"
    from_port           = 8081
    to_port             = 8090
    cidr_blocks         = [ var.GW_01_SVR_ADDR, var.GW_02_SVR_ADDR, var.GW_01_SVR_PUB_ADDR, var.GW_02_SVR_PUB_ADDR ]
    description         = "Extra/Gateway Server"
  }

  ingress {
    protocol            = "tcp"
    from_port           = 8081
    to_port             = 8090
    cidr_blocks         = var.vpc_create_flag == "1" ? [ aws_vpc.create_vpc[count.index].cidr_block ]:[ data.aws_vpc.get_vpc[count.index].cidr_block ]
    description         = "Extra/Peer EIP"
  }

  egress {
    protocol		= "-1"
    from_port		= 0
    to_port	    	= 0
    cidr_blocks		= ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "create_sg_websocket_9999" {
  count           = var.vpc_create_flag == "0" ? "1" : "1"
  name            = "${var.network_node_name}_${var.sg_name}_websoket_9999"
  description     = "${var.network_node_name}_${var.sg_name}_websoket_9999"
  vpc_id          = var.vpc_create_flag == "1" ? aws_vpc.create_vpc[count.index].id : data.aws_vpc.get_vpc[count.index].id

  tags = {
    Name          = "${var.network_node_name}_${var.sg_name}_websoket_9999"
  }

  ingress {
    protocol            = "tcp"
    from_port           = 9999
    to_port             = 9999
    cidr_blocks         = [ local.subnet_cidr_01, local.subnet_cidr_02 ]
    description         = "Goloop-control/AWS Availability ZONE - CIDR "
  }

  ingress {
    protocol            = "tcp"
    from_port           = 9999
    to_port             = 9999
    cidr_blocks         = [ var.IL_PUB_ADDR_SKT, var.IL_VPN_ADDR_SKT, var.IL_LAN_ADDR_SKT ]
    description         = "Goloop-control/IL SKT LINE"
  }

  ingress {
    protocol            = "tcp"
    from_port           = 9999
    to_port             = 9999
    cidr_blocks         = [ var.IL_PUB_ADDR_KT, var.IL_VPN_ADDR_KT, var.IL_LAN_ADDR_KT ]
    description         = "Goloop-control/IL KT Line"
  }

  ingress {
    protocol            = "tcp"
    from_port           = 9999
    to_port             = 9999
    cidr_blocks         = [ var.GW_01_SVR_ADDR, var.GW_02_SVR_ADDR, var.GW_01_SVR_PUB_ADDR, var.GW_02_SVR_PUB_ADDR ]
    description         = "Goloop-control/Gateway Server"
  }

  egress {
    protocol		= "-1"
    from_port		= 0
    to_port		    = 0
    cidr_blocks		= ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "create_sg_ngrinder" {
  count             = var.vpc_create_flag == "0" ? "1" : "1"
  name		  	    = "${var.network_node_name}_${var.sg_name}_ngrinder"
  description  	    = "${var.network_node_name}_${var.sg_name}_ngrinder"
  vpc_id	  	    = var.vpc_create_flag == "1" ? aws_vpc.create_vpc[count.index].id : data.aws_vpc.get_vpc[count.index].id

  tags = {
    Name	  	    = "${var.network_node_name}_${var.sg_name}_ngrinder"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 12000
    to_port         = 12009
    cidr_blocks     = var.vpc_create_flag == "1" ? [ aws_vpc.create_vpc[count.index].cidr_block ]:[ data.aws_vpc.get_vpc[count.index].cidr_block ]
    description     = "ngrinder"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 16001
    to_port         = 16001
    cidr_blocks     = var.vpc_create_flag == "1" ? [ aws_vpc.create_vpc[count.index].cidr_block ]:[ data.aws_vpc.get_vpc[count.index].cidr_block ]
    description     = "ngrinder"
  }

  egress {
    protocol		= "-1"
    from_port		= 0
    to_port		    = 0
    cidr_blocks		= ["0.0.0.0/0"]
  }
}
