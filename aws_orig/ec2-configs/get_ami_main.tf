### Terraform v0.14.7
### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami


data "aws_ami" "get_ami" {
  most_recent= true
  owners    = [var.default_ami[var.ami_name]["owner_id"]]
  name_regex = var.default_ami[var.ami_name]["name"]

#  filter {
#   name   = "owner-alias"
#   values = [var.default_ami[var.ami_name]["alias_name"]]
#  }

  filter {
    name   = "name"
    values = [var.default_ami[var.ami_name]["filter_name"]]
  }
  
  filter {
    name   = "architecture"
    values = [var.default_ami[var.ami_name]["arch_type"]]
  }
}

