#### Terraform v0.14.7
#### ALB Setting  - ### Load balancer Type [ alb = application , nlb = network ]
#####   https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
resource "aws_lb" "create_fe-alb" {
  count				= var.lb_set_flag == "1" ? "1" : "0"
  name				= "${var.network_node_name}-${var.lb_alb_name}"
  internal			= false
  load_balancer_type		= "application"            				### Loard balancer Type [ alb = application , nlb = network ]
  #security_groups		= [ "${aws_security_group.create_sg_alb[0].*.id}" ]
  security_groups		= [ aws_security_group.create_sg_alb[0].id ]
  #subnets			= [ data.aws_subnet.get_subnet_01.*.id, data.aws_subnet.get_subnet_02.*.id ] 
  #subnets			= var.lb_set_flag == "1" ? [ aws_subnet.create_subnet_01[0].id, aws_subnet.create_subnet_02[0].id ] : [ data.aws_subnet.get_subnet_01[0].id, data.aws_subnet.get_subnet_02[0].id ] 
  #subnets			= var.lb_set_flag == "1" ? tolist( aws_subnet.create_subnet_01[0].id, aws_subnet.create_subnet_02[0].id ) : tolist( data.aws_subnet.get_subnet_01[0].id, data.aws_subnet.get_subnet_02[0].id )
  #subnets			= var.lb_set_flag == "1" ? tolist(aws_subnet.create_subnet_01.*.id, aws_subnet.create_subnet_02.*.id) : tolist(data.aws_subnet.get_subnet_01[*].id, data.aws_subnet.get_subnet_02[*].id)

  enable_deletion_protection	= false    					### 삭제 방지   , true 일 경우 terraform에서 생성은 되나 삭제 불가 

  subnet_mapping {
    subnet_id     = var.lb_set_flag == "1" ? var.vpc_create_flag == "1" ? aws_subnet.create_subnet_01[0].id : data.aws_subnet.get_subnet_01[0].id : ""
    #allocation_id = aws_eip.example1.id
  }

  subnet_mapping {
    subnet_id     = var.lb_set_flag == "1" ? var.vpc_create_flag == "1" ? aws_subnet.create_subnet_02[0].id : data.aws_subnet.get_subnet_02[0].id : ""
    #allocation_id = aws_eip.example2.id
  }

  tags = {
    Name = "${var.network_node_name}-${var.lb_alb_name}"
  }

  lifecycle { create_before_destroy = true }
}


#####+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##################################################################################################
### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener

### Port redirect  http to https ( 80 -> 443)
resource "aws_lb_listener" "create_fe_redirect_80to443" {
  count			= var.lb_set_flag == "1" ? 1 : 0
  load_balancer_arn	= aws_lb.create_fe-alb[count.index].arn
  port	 		= "80"
  protocol		= "HTTP"

  default_action {
    type		= "redirect"

    redirect {
      port	    	= "443"
      protocol		= "HTTPS"
      status_code	= "HTTP_301"
    }
  }
}

### Default listener 443 port 
resource "aws_lb_listener" "create_fe_forword_443" {
  count			    = var.lb_set_flag == "1" ? 1 : 0
  load_balancer_arn	= aws_lb.create_fe-alb[count.index].arn
  port			    = "443"
  protocol		    = "HTTPS"
  ssl_policy		= var.lb_ssl_policy_name
  certificate_arn	= aws_acm_certificate.create_fe_cert[count.index].arn
  

  default_action {
    type		      = "forward"
    target_group_arn  = aws_lb_target_group.create_fe-alb-target-group[count.index].arn
  }
}




#####+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##################################################################################################
#### ALB Setting 
### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group

resource "aws_lb_target_group" "create_fe-alb-target-group" {
  count				= var.lb_set_flag == "1" ? 1 : 0
  name				= "${var.network_node_name}-${var.lb_alb_tg_name}"
  port				= var.lb_tg_port
  protocol			= "HTTP"
  vpc_id			= var.vpc_create_flag == "1" ? aws_vpc.create_vpc[count.index].id : data.aws_vpc.get_vpc[count.index].id

  health_check {
    interval		    	= 10
    path		    	    = var.health_check_path		 #"/api/v1/avail/peer"
    healthy_threshold		= 3
    unhealthy_threshold		= 2
  }

  tags = { 
    Name = "${var.network_node_name}-${var.lb_alb_tg_name}"
  }
}


### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
resource "aws_lb_target_group_attachment" "tg_attach" {
  count             = var.lb_set_flag == "1" ? var.create_instance_count : 0
  target_group_arn	= aws_lb_target_group.create_fe-alb-target-group[0].arn
  target_id		    = element(var.module_instance_ids,count.index)
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


resource "aws_acm_certificate" "create_fe_cert" {
  count             = var.lb_set_flag == "1" ? "1" : "0"
  domain_name		= var.cert_domain_name
  validation_method	= "DNS"
  tags = {
      Name          = "${var.network_node_name}_${var.cert_tag_name}"
  }

  lifecycle { create_before_destroy = true }
}

####  LB Certificate Setting
resource "aws_lb_listener_certificate" "Set_fe_cert" {
  count             = var.lb_set_flag == "1" ? "1" : "0"
  listener_arn      = aws_lb_listener.create_fe_forword_443[count.index].arn
  certificate_arn   = aws_acm_certificate.create_fe_cert[count.index].arn
}

