#### Terraform v0.14.7
###  https://registry.terraform.io/providers/hashicorp/aws/latest/docs

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  #region = "ap-northeast-2"
  #region = "ap-northeast-1"
  region = var.aws_region
  # export AWS_ACCESS_KEY_ID="accesskey"
  # export AWS_SECRET_ACCESS_KEY="asecretkey"
}

provider "aws" {
  ### Tokyo region
  alias="tokyo"
  region = "ap-northeast-1"
}

provider "aws" {
  ### Singapore region
  alias="singapore"
  region = "ap-southeast-1"
}

provider "aws" {
  ### Califonia region
  alias="califonia"
  region = "us-west-1"
}

provider "aws" {
  ### Turing tokyo region
  alias="switch_role_turing"
  region = "ap-northeast-1"

  assume_role {
    role_arn = "arn:aws:iam::650435989917:role/t_infra"
  }
}

data "aws_region" "current" {}
