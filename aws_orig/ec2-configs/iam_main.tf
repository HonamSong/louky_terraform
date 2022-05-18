## Terraform v0.14.7
### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_instance_profile
### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role


data "aws_iam_role" "get_iam_role" {
  name = var.iam_role_name
}


data "aws_iam_instance_profile" "get_iam_profile" {
  name = var.iam_role_name
}
