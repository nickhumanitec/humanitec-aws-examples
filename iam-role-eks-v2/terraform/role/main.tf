variable "role_name" {
  default = "humanitec-"
}
variable "policies" { type = set(string) }
variable "cluster_oidc" {}
variable "namespace" { default = "*" }
variable "service_account" { default = "*" }

resource "aws_iam_role_policy_attachment" "policies" {
  for_each   = var.policies
  role       = aws_iam_role.eks.name
  policy_arn = each.value
}

resource "aws_iam_role" "eks" {
  name_prefix = var.role_name
  // below uses StringLike to allow wildcards for multiple service accounts within the same namespace for workloads
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${var.cluster_oidc}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${var.cluster_oidc}:sub" : "system:serviceaccount:${var.namespace}:${var.service_account}",
            "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${var.cluster_oidc}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
    }
  )

  tags = {
    Humanitec = "true"
  }

}

output "arn" {
  value = aws_iam_role.eks.arn
}

output "role_arn" {
  value = aws_iam_role.eks.arn
}

output "role_name" {
  value = aws_iam_role.eks.name
}

output "role_id" {
  value = aws_iam_role.eks.id
}

// boilerplate for Humanitec terraform driver
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "assume_role_arn" {}

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
    role_arn = var.assume_role_arn
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
