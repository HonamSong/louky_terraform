
locals {
  instance_names   = sort(concat(aws_instance.post_ec2_instance[*].tags["Name"]))
  instance_name    = sort(concat(aws_instance.post_ec2_instance[*].tags["Name"]))
  eip_public_ips   = concat(aws_eip.post_eip.*.public_ip)
  eip_private_ips  = concat(aws_eip.post_eip.*.private_ip)
  eip_ids          = concat(aws_eip.post_eip.*.id)
}

resource "aws_eip" "post_eip" {
  count = var.create_instance_count    # ToDo : var.eip_set_flag?
  vpc = true
  instance = element(aws_instance.post_ec2_instance.*.id,count.index)

  tags = {
    Name = aws_instance.post_ec2_instance[count.index].tags["Name"]
  }
}

resource "time_sleep" "wait_time" {
  depends_on = [aws_eip.post_eip]
  create_duration = "15s"
}


data "aws_eip" "get_eip_address" {
  count = length(local.instance_names)

  filter {
    name   = "tag:Name"
    values = [element(local.instance_names, count.index)]
  }
  depends_on = [
    time_sleep.wait_time
  ]
}


### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance
data "aws_instance" "get_instance_ip" {
  count = length(local.instance_names)

  filter {
    name   = "tag:Name"
    values = [element(local.instance_names, count.index)]
  }

  depends_on = [
    data.aws_eip.get_eip_address
  ]

}

# output #########################################################################################3
output "print_sort_eip" {
  value = tolist(data.aws_eip.get_eip_address.*.public_ip)
}

output "print_eip_public_ips" {
  value = local.eip_public_ips
}

output "print_eip_private_ips" {
  value = local.eip_private_ips
}

output "print_eip_id_lists" {
  value = local.eip_ids
}