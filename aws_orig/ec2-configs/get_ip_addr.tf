### Terraform v0.14.7
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eip


locals {
  instance_names         = sort(concat(aws_instance.create_instance[*].tags["Name"]))
}

resource "time_sleep" "wait_time" {
  depends_on = [aws_eip.create_eip]

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
