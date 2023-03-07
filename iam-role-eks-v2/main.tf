variable "humanitec_organization" {}
variable "humanitec_token" {}
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "cluster_oidc" {}

variable "terraform_role" {}


variable "app_name" {}
variable "workload_name" {}


terraform {
  required_providers {
    humanitec = {
      source = "humanitec/humanitec"
    }
  }
}

provider "humanitec" {
  org_id = var.humanitec_organization
  token  = var.humanitec_token
}

resource "humanitec_application" "app" {
  id   = var.app_name
  name = var.app_name
}


resource "humanitec_resource_definition" "aws_terraform_resource_s3_bucket" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "${var.app_name}-eks-iam-s3-bucket"
  name        = "${var.app_name}-eks-iam-s3-bucket"
  type        = "s3"

  criteria = [
    {
      app_id = humanitec_application.app.id
      res_id = "modules.${var.workload_name}.externals.${var.app_name}-eks-iam-s3-bucket"
    }
  ]

  driver_inputs = {
    secrets = {
      variables = jsonencode({
        access_key = var.access_key
        secret_key = var.secret_key
      })
    },
    values = {
      "source" = jsonencode(
        {
          path = "s3/terraform/bucket"
          rev  = "refs/heads/main"
          url  = "https://github.com/nickhumanitec/humanitec-aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          region          = var.region
          bucket          = "${var.app_name}-eks-iam-s3-bucket-$${context.app.id}-$${context.env.id}"
          assume_role_arn = var.terraform_role
        }
      )
    }
  }

}

resource "humanitec_resource_definition" "aws_terraform_resource_policy" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "${var.app_name}-eks-iam-policy"
  name        = "${var.app_name}-eks-iam-policy"
  type        = "aws-policy"

  criteria = [
    {
      app_id = humanitec_application.app.id
      res_id = "modules.${var.workload_name}.externals.${var.app_name}-eks-iam-policy"
    }
  ]

  driver_inputs = {
    secrets = {
      variables = jsonencode({
        access_key = var.access_key
        secret_key = var.secret_key
      })
    },
    values = {
      "source" = jsonencode(
        {
          path = "iam-role-eks/terraform/policy/"
          rev  = "refs/heads/iam-test"
          url  = "https://github.com/nickhumanitec/humanitec-aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          region          = var.region
          parameter_arn   = "$${resources.s3#modules.${var.workload_name}.externals.${var.app_name}-eks-iam-s3-bucket.outputs.arn}"
          assume_role_arn = var.terraform_role
          name            = "humanitec-testpolicy"
        }
      )
    }
  }

}
