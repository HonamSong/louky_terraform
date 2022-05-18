### Terraform v0.14.7


#### Print EIP 

locals {
  instance_name 	= sort(concat(aws_instance.create_instance[*].tags["Name"]))
  eip_public_ips	= concat(aws_eip.create_eip.*.public_ip)
  eip_private_ips	= concat(aws_eip.create_eip.*.private_ip)
  eip_ids 		= concat(aws_eip.create_eip.*.id)
 
}


output "print_instance_name" {
  value = local.instance_name
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


### Instance ID 
output "Instance_ids" {
  value = tolist(aws_instance.create_instance.*.id)
}

#### print Instance private IP
output "print_private_ips" {
  value = tolist(data.aws_instance.get_instance_ip.*.private_ip)
}

output "print_public_ips" {
  value = tolist(data.aws_instance.get_instance_ip.*.public_ip)
}

output "print_instanceType_real" {
  value = tolist(data.aws_instance.get_instance_ip.*.instance_type)
}


 ### Print AMI Info
output "ami_arn" {
  #value = data.aws_ami.get_ami.arn
  value = formatlist("%-31s = %s", "arn", [data.aws_ami.get_ami.arn])
}

output "ami_architecture" {
  #value = data.aws_ami.get_ami.architecture
  value = formatlist("%-31s = %s", "architectur", [data.aws_ami.get_ami.architecture])
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


## print iam role 
output "print_iam_id" {
  value = data.aws_iam_role.get_iam_role.id
}

output "print_iam_arn" {
  value = data.aws_iam_role.get_iam_role.arn
}

output "print_iam_role_name" {
  value = data.aws_iam_instance_profile.get_iam_profile.role_name
}

output "print_iam_profile_id" {
  value = data.aws_iam_instance_profile.get_iam_profile.role_id
}




#### sort bu instance EIP
output "print_sort_eip" {
  value = tolist(data.aws_eip.get_eip_address.*.public_ip)
}

##### instance id list
output "print_ec2_ids" {
  value = data.aws_instances.get_instance_peer_list.ids
}



output "print_ctz_count" { 
  value = local.ctz_count
}
output "print_last_count" { 
  value = local.last_count
}
