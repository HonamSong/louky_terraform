# icon-ec2 > ami.tf

data "aws_ami" "get_ami" {
  most_recent= true
  owners    = [ var.default_ami[var.ami_name]["owner_id"] ]
  name_regex = var.default_ami[var.ami_name]["name"]

  #  filter {
  #   name   = "owner-alias"
  #   values = [var.default_ami[var.ami_name]["alias_name"]]
  #  }

  filter {
	name   = "name"
	values = [
	  var.default_ami[var.ami_name]["filter_name"]
	]
  }

  filter {
	name   = "architecture"
	values = [
	  var.default_ami[var.ami_name]["arch_type"]
	]
  }
}


### Print AMI Info
output "ami_arn" {
  #value = data.aws_ami.get_ami.arn
  value = formatlist("%-31s = %s", "arn", [data.aws_ami.get_ami.arn])
}

output "ami_architecture" {
  #value = data.aws_ami.get_ami.architecture
  value = formatlist("%-31s = %s", "architecture", [data.aws_ami.get_ami.architecture])
}

output "ami_id" {
  #value = data.aws_ami.get_ami.image_id
  value = formatlist("%-31s = %s", "image_id", [data.aws_ami.get_ami.image_id])
}

output "ami_image_location" {
  #value = data.aws_ami.get_ami.image_location
  value = formatlist("%-31s = %s", "image_location", [data.aws_ami.get_ami.image_location])
}

output "ami_image_name" {
  #value = data.aws_ami.get_ami.name
  value = formatlist("%-31s = %s", "image_name", [data.aws_ami.get_ami.name])
}