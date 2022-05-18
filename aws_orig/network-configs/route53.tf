### Terraform v0.14.7
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record

data "aws_route53_zone" "check_dns_zone" {
  name = var.dns_zone_name
}

resource "time_sleep" "wait_time_route53" {
  depends_on = [ aws_lb_listener_certificate.Set_fe_cert ]

  create_duration = "10s"
}

resource "aws_route53_record" "create_route53_record" {
  #count 	= var.route53_set_flag == "1" ? "1" : "0"
  count 	= var.route53_set_flag == "0" ? "0" : var.lb_set_flag == "1" ? "1" : "0"
  zone_id 	= data.aws_route53_zone.check_dns_zone.zone_id
  #name    	= "${var.route53_record_name}.${var.dns_zone_name}"
  name    	= local.route53_recode_name
  type    	= "A"
  #ttl     	= "300"     ### optional - alias 가 아닐 경우 필요 

  alias {
    name                   = var.lb_set_flag == "1" ? "dualstack.${aws_lb.create_fe-alb[count.index].dns_name}" : ""
    zone_id                = var.lb_set_flag == "1" ? aws_lb.create_fe-alb[count.index].zone_id : ""
    evaluate_target_health = var.lb_set_flag == "1" ? true : false
  }

  depends_on = [
    time_sleep.wait_time_route53
  ]

}

