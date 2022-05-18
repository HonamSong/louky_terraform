## Terraform v0.14.7
### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association



## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
resource "aws_eip" "create_eip" {
  count = var.create_instance_count
  vpc = true
  instance = element(aws_instance.create_instance.*.id,count.index)

  tags = {
    #Name = format("%s-%02d", local.InstanceName, count.index + 1)
    #Name = format("%s-%02d", (local.last_count == count.index ? local.InstanceName_trk : local.InstanceName), (local.last_count == count.index ? "1" : (count.index + 1)))
    Name = aws_instance.create_instance[count.index].tags["Name"]

  }
}




############################################################################################################################################
############################################################################################################################################
############################################################################################################################################
############################################################################################################################################
############################################################################################################################################
############################################################################################################################################
###  
###    ____                       _ _            ____
###   / ___|  ___  ___ _   _ _ __(_) |_ _   _   / ___|_ __ ___  _   _ _ __
###   \___ \ / _ \/ __| | | | '__| | __| | | | | |  _| '__/ _ \| | | | '_ \
###    ___) |  __/ (__| |_| | |  | | |_| |_| | | |_| | | | (_) | |_| | |_) |
###   |____/ \___|\___|\__,_|_|  |_|\__|\__, |  \____|_|  \___/ \__,_| .__/
###                                     |___/                        |_|
 
##### Add rule Web_socket
resource "aws_security_group_rule" "add_sg_rule_websocket_01_7100" {
  count 	    = var.create_instance_count
  type              = "ingress"
  from_port         = 7100
  to_port           = 7100
  protocol          = "tcp"
  security_group_id = var.module_sg_websoket_7100
  cidr_blocks       = ["${aws_eip.create_eip[count.index].public_ip}/32"]
  description       = "ICON Service - Elastic IP"
}

resource "aws_security_group_rule" "add_sg_rule_websocket_01_9000" {
  count 	    = var.create_instance_count
  type              = "ingress"
  from_port         = 9000
  to_port           = 9000
  protocol          = "tcp"
  security_group_id = var.module_sg_websoket_9000
  cidr_blocks       = ["${aws_eip.create_eip[count.index].public_ip}/32"]
  description       = "PREP RPC Service - Elastic IP"
}

resource "aws_security_group_rule" "add_sg_rule_websocket_01_9900" {
  count             = var.create_instance_count
  type              = "ingress"
  from_port         = 9900
  to_port           = 9900
  protocol          = "tcp"
  security_group_id = var.module_sg_websoket_9900
  cidr_blocks       = ["${aws_eip.create_eip[count.index].public_ip}/32"]
  description       = "Proxy/Prep Elastic IP"
}

resource "aws_security_group_rule" "add_sg_rule_websocket_01_9999" {
  count             = var.create_instance_count
  type              = "ingress"
  from_port         = 9999
  to_port           = 9999
  protocol          = "tcp"
  security_group_id = var.module_sg_websoket_9999
  cidr_blocks       = ["${aws_eip.create_eip[count.index].public_ip}/32"]
  description       = "Goloop-control/Prep Elastic IP"
}

resource "aws_security_group_rule" "add_sg_rule_websocket_01_8081_8090" {
  count             = var.create_instance_count
  type              = "ingress"
  from_port         = 8081
  to_port           = 8090
  protocol          = "tcp"
  security_group_id = var.module_sg_websoket_8081_8090
  cidr_blocks       = ["${aws_eip.create_eip[count.index].public_ip}/32"]
  description       = "Extra/Prep Elastic IP"
}

resource "aws_security_group_rule" "add_sg_ngrinder_01_12000_12009" {
  count             = var.create_instance_count
  type              = "ingress"
  from_port         = 12000
  to_port           = 12009
  protocol          = "tcp"
  security_group_id = var.module_sg_ngrinder
  cidr_blocks       = ["${aws_eip.create_eip[count.index].public_ip}/32"]
  description       = "Extra/Prep Elastic IP"
}

resource "aws_security_group_rule" "add_sg_ngrinder_01_16001" {
  count             = var.create_instance_count
  type              = "ingress"
  from_port         = 16001
  to_port           = 16001
  protocol          = "tcp"
  security_group_id = var.module_sg_ngrinder
  cidr_blocks       = ["${aws_eip.create_eip[count.index].public_ip}/32"]
  description       = "Extra/Prep Elastic IP"
}
