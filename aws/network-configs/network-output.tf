### Terraform v0.14.7

output "vpc_info" {
  value = var.vpc_create_flag == "1" ? aws_vpc.create_vpc[0].* : data.aws_vpc.get_vpc[0].*
}

output "LoadBalancer_id" {
  value = var.lb_set_flag == "1" ? aws_lb.create_fe-alb[0].id : "Not Setting Flag(flag:${var.lb_set_flag})"
}

output "LoadBalancer_dnsname" {
  value = var.lb_set_flag == "1" ? aws_lb.create_fe-alb[0].dns_name : "Not Setting Flag(flag:${var.lb_set_flag})"
}

output "az_subnet_01" {
  #value = data.aws_subnet.get_subnet_01.id
  value = var.vpc_create_flag == "1" ? aws_subnet.create_subnet_01[0].id : data.aws_subnet.get_subnet_01[0].id
}

output "az_subnet_02" {
  #value = data.aws_subnet.get_subnet_02.id
  value = var.vpc_create_flag == "1" ? aws_subnet.create_subnet_02[0].id : data.aws_subnet.get_subnet_02[0].id
}

## security group 
output "sg_ssh" {
  value = length(aws_security_group.create_sg_ssh_connection) > "0" ? aws_security_group.create_sg_ssh_connection[0].id : ""
}

output "sg_websocket" {
  value = length(aws_security_group.create_sg_websocket) > "0" ?  aws_security_group.create_sg_websocket[0].id : ""
}

output "sg_alb" {
  value = length(aws_security_group.create_sg_alb) > "0" ?  aws_security_group.create_sg_alb[0].id : ""
}

output "sg_websocket_9900" {
  value = length(aws_security_group.create_sg_websocket_9900) > "0" ?  aws_security_group.create_sg_websocket_9900[0].id : ""
}
output "sg_websocket_9999" {
  value = length(aws_security_group.create_sg_websocket_9999) > "0" ?  aws_security_group.create_sg_websocket_9999[0].id : ""
}
output "sg_websocket_8081_8090" {
  value = length(aws_security_group.create_sg_websocket_8081_8090) > "0" ?  aws_security_group.create_sg_websocket_8081_8090[0].id : ""
}
output "sg_ngrinder" {
  value = length(aws_security_group.create_sg_ngrinder) > "0" ?  aws_security_group.create_sg_ngrinder[0].id : ""
}

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### route53
output "print_route53_zone_id" {
  value = length(data.aws_route53_zone.check_dns_zone) > "0" ? data.aws_route53_zone.check_dns_zone.zone_id : ""
}

output "print_route53_add_name" {
 value = length(aws_route53_record.create_route53_record) > "0" ? aws_route53_record.create_route53_record[0].name : "Not Setting Flag(flag:${var.route53_set_flag})"
}

output "print_route53_add_fqdn" {
 value = length(aws_route53_record.create_route53_record) > "0" ? aws_route53_record.create_route53_record[0].fqdn : "Not Setting Flag(flag:${var.route53_set_flag})"
}




#### test 
output "print_subnet_cidr_01" {
  value = var.vpc_create_flag == "1" ? aws_subnet.create_subnet_01[0].cidr_block : data.aws_subnet.get_subnet_01[0].cidr_block 
}
output "print_subnet_cidr_02" {
  value = var.vpc_create_flag == "1" ? aws_subnet.create_subnet_02[0].cidr_block : data.aws_subnet.get_subnet_02[0].cidr_block 
}
