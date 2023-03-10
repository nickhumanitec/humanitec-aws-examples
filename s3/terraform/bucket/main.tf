variable "bucket" {}

resource "aws_s3_bucket" "b" {
  bucket = var.bucket
  tags = {
    Humanitec = true
  }
}

output "bucket" {
  value = aws_s3_bucket.b.bucket
}

output "region" {
  value = var.region
}

output "aws_access_key_id" {
  value     = ""
  sensitive = true
}

output "aws_secret_access_key" {
  value     = ""
  sensitive = true
}

// boilerplate for Humanitec terraform driver
variable "region" {}
variable "access_key" {}
variable "secret_key" {}

variable "assume_role_arn" {}
# variable "assume_role_session_name" {}
# variable "assume_role_external_id" {}

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
    # session_name = var.assume_role_session_name
    # external_id  = var.assume_role_external_id
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
