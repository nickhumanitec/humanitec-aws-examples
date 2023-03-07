variable "policy_ssm_name" {
  default = "humanitec-"
}

variable "parameter_arn" {
}

resource "aws_iam_policy" "policy_ssm" {
  name_prefix = var.policy_ssm_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "SSMGeneral",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameter"
        ],
        "Resource" : "${var.parameter_arn}"
      }
    ]
  })
  tags = {
    Humanitec = "true"
  }
}

output "arn" {
  value = aws_iam_policy.policy_ssm.arn
}

output "policy_ssm_arn" {
  value = aws_iam_policy.policy_ssm.arn
}

output "policy_ssm_name" {
  value = aws_iam_policy.policy_ssm.name
}

output "policy_ssm_id" {
  value = aws_iam_policy.policy_ssm.policy_id
}

// boilerplate for Humanitec terraform driver
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "terraform_assume_role_arn" {}


terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  assume_role {
    role_arn = var.terraform_assume_role_arn
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
