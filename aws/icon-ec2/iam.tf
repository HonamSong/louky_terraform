


data "aws_iam_role" "get_iam_role" {
  name = var.iam_role_name
}


data "aws_iam_instance_profile" "get_iam_profile" {
  name = var.iam_role_name
}



## print iam role
output "print_iam_id" {
  value = data.aws_iam_role.get_iam_role.id
}

output "print_iam_arn" {
  value = data.aws_iam_role.get_iam_role.arn
}

output "print_iam_instance_profile_name" {
  value = data.aws_iam_instance_profile.get_iam_profile.role_name
}

output "print_iam_instance_profile_id" {
  value = data.aws_iam_instance_profile.get_iam_profile.role_id
}