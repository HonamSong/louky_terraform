# lb - alb.tf

##   수정중!!!! ------------------------------------------------------------------------------
locals {
#  subnet_id_01 = var.vpc_create_flag == "1" ? aws_subnet.post_subnet[0].id : data.aws_subnet.get_subnet[0].id
#  subnet_id_02 = var.vpc_create_flag == "1" ? aws_subnet.post_subnet[1].id : data.aws_subnet.get_subnet[1].id
  vpc_info     = var.module_vpc_info
  subnet_id_01 = var.module_subnet_ids[0].id
  subnet_id_02 = var.module_subnet_ids[1].id
}

#### ALB Setting  - ### Load balancer Type [ alb = application , nlb = network ]
#####   https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb

resource "aws_lb" "post_fe_alb" {
  count                         = var.alb_set_flag == "1" ? "1" : "0"
  name                          = "${var.network_node_name}-${var.alb_name}"
  internal                      = false
  load_balancer_type            = "application"     				### Load Balancer Type [ alb = application , nlb = network ]
#  security_groups		        = [ aws_security_group.post_sg_alb_port[0].id ]
  security_groups		        = [ var.module_sg_alb[0].id ]
  enable_deletion_protection    = false    					### 삭제 방지 , true 일 경우 terraform 을 통해 생성은 되나 삭제 불가

  subnet_mapping {
	#subnet_id     = var.alb_set_flag == "1" ? var.vpc_create_flag == "1" ? aws_subnet.post_subnet[0].id : data.aws_subnet.get_subnet[0].id : ""
	subnet_id     = var.alb_set_flag == "1" ? local.subnet_id_01 : ""
	#allocation_id = aws_eip.example1.id
  }

  subnet_mapping {
	#subnet_id     = var.lb_set_flag == "1" ? var.vpc_create_flag == "1" ? aws_subnet.post_subnet[1].id : data.aws_subnet.get_subnet[1].id : ""
	subnet_id     = var.alb_set_flag == "1" ? local.subnet_id_02 : ""
	#allocation_id = aws_eip.example2.id
  }

  tags = {
	Name = "${var.network_node_name}-${var.alb_name}"
  }

  lifecycle { create_before_destroy = true }
}


#####+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##################################################################################################
### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener

### Port redirect  http to https ( 80 -> 443)
resource "aws_lb_listener" "post_fe_redirect_80to443" {
  count	              = var.alb_set_flag == "1" ? 1 : 0
  load_balancer_arn   = aws_lb.post_fe_alb[count.index].arn
  port                = "80"
  protocol            = "HTTP"

  default_action {
	type              = "redirect"

	redirect {
	  port            = "443"
	  protocol        = "HTTPS"
	  status_code     = "HTTP_301"
	}
  }
}

### Default listener 443 port
resource "aws_lb_listener" "post_fe_forward_443" {
  count               = var.alb_set_flag == "1" ? 1 : 0
  load_balancer_arn   = aws_lb.post_fe_alb[count.index].arn
  port                = "443"
  protocol            = "HTTPS"
  ssl_policy          = var.alb_ssl_policy_name
  certificate_arn     = aws_acm_certificate.post_fe_acm_cert[count.index].arn


  default_action {
	type              = "forward"
	target_group_arn  = aws_lb_target_group.post_fe_alb_tg[count.index].arn
  }
}


#####+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##################################################################################################
#### ALB Setting
### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group

resource "aws_lb_target_group" "post_fe_alb_tg" {
  count				= var.alb_set_flag == "1" ? 1 : 0
  name				= "${var.network_node_name}-${var.alb_tg_name}"
  port				= var.alb_tg_port
  protocol			= "HTTP"
  #vpc_id			= var.vpc_create_flag == "1" ? aws_vpc.post_vpc[count.index].id : data.aws_vpc.get_vpc[count.index].id
  vpc_id			= local.vpc_info[0].id

  health_check {
	interval		    	= var.alb_hc_interval
	path		    	    = var.alb_health_check_path		 #"/api/v1/avail/peer"
	healthy_threshold		= var.alb_hc_threshold
	unhealthy_threshold		= var.alb_unhc_threshold
  }

  tags = {
	Name = "${var.network_node_name}-${var.alb_tg_name}"
  }
}


### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
resource "aws_lb_target_group_attachment" "tg_attach" {
  count             = var.alb_set_flag == "1" ? length(var.module_ec2_ids) : 0
  target_group_arn	= aws_lb_target_group.post_fe_alb_tg[0].arn
  target_id		    = element(var.module_ec2_ids, count.index)
}


#####+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##################################################################################################
### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate


##################################################################################################
# Find a certificate that is key_types
#data "aws_acm_certificate" "network_certificate" {
#  domain		= "net.solidwallet.io"
#  key_types		= ["RSA_2048"]
#}
##################################################################################################


resource "aws_acm_certificate" "post_fe_acm_cert" {
  count             = var.alb_set_flag == "1" ? "1" : "0"
  domain_name       = var.cert_domain_name
  validation_method	= "DNS"
  tags = {
	Name            = "${var.network_node_name}_${var.cert_tag_name}"
  }

  lifecycle { create_before_destroy = true }
}

####  LB Certificate Setting
resource "aws_lb_listener_certificate" "post_fe_listener_cert" {
  count             = var.alb_set_flag == "1" ? "1" : "0"
  listener_arn      = aws_lb_listener.post_fe_forward_443[count.index].arn
  certificate_arn   = aws_acm_certificate.post_fe_acm_cert[count.index].arn
}

output "LB_post_fe_alb" {
  value = aws_lb.post_fe_alb
}