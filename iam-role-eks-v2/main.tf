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
  host   = "https://dev-api.humanitec.io/"
}

resource "humanitec_application" "app" {
  id   = var.app_name
  name = var.app_name
}


resource "humanitec_resource_definition" "aws_terraform_resource_s3_bucket" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "${var.app_name}-s3"
  name        = "${var.app_name}-s3"
  type        = "s3"

  criteria = [
    {
      app_id = humanitec_application.app.id
      res_id = "modules.${var.workload_name}.externals.${var.app_name}-s3"
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
          bucket          = "${var.app_name}-s3-$${context.app.id}-$${context.env.id}"
          assume_role_arn = var.terraform_role
        }
      )
    }
  }

}

resource "humanitec_resource_definition" "aws_terraform_resource_policy" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "${var.app_name}-policy"
  name        = "${var.app_name}-policy"
  type        = "aws-policy"

  criteria = [
    {
      # app_id = humanitec_application.app.id
      res_id = "${var.app_name}-policy"
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
          path = "iam-role-eks-v2/terraform/policy/"
          rev  = "refs/heads/iam-test"
          url  = "https://github.com/nickhumanitec/humanitec-aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          region          = var.region
          arn             = "arn:aws:s3:::mar7test-s3-mar7test-development"
          assume_role_arn = var.terraform_role
          policy_name     = "xx"
        }
      )
    }
  }

}


resource "humanitec_resource_definition" "workload" {
  count = 1
  id    = "${var.app_name}-workload"
  name  = "${var.app_name}-workload"
  type  = "workload"

  criteria = [
    {
      app_id = humanitec_application.app.id
      res_id = "modules.${var.workload_name}"
    }
  ]

  driver_type = "humanitec/template"
  driver_inputs = {
    secrets = {
      templates = jsonencode({
        outputs = ""
      })
    },
    values = {
      templates = jsonencode({
        cookie    = ""
        init      = ""
        manifests = <<EOL
serviceaccount.yaml:
  data:
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: $${context.app.id}-$${context.env.id}-${var.workload_name}
      annotations:

        x: $${resources.aws-policy#mar7test-policy.outputs.arn}
        context: {{trimPrefix "modules." "$${context.res.id}"}}
        fullContext: $${context.res.id}
        app: $${context.app.id}
        env: $${context.env.id}
  location: namespace
EOL
        outputs   = ""
      })
    }
  }
}
