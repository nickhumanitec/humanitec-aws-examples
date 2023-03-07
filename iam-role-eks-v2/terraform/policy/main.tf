variable "policy_name" {}

variable "arn" {}

resource "aws_iam_policy" "policy" {
  name = var.policy_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "S3Admin",
        "Effect" : "Allow",
        "Action" : [
          "s3:*"
        ],
        "Resource" : ["${var.arn}", "${var.arn}/*"]
      }
    ]
  })
  tags = {
    Humanitec = "true"
  }
}

output "arn" {
  value = aws_iam_policy.policy.arn
}

output "policy_arn" {
  value = aws_iam_policy.policy.arn
}

output "policy_name" {
  value = aws_iam_policy.policy.name
}

output "policy_id" {
  value = aws_iam_policy.policy.policy_id
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
