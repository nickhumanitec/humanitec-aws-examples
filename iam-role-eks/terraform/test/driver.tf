
# Driver example

# apply must be done in two parts (as policies are dynamically injected)
# this works inside a humanitec manifest workload, but within a terraform file doen't as 
# it needs to know the policies ARNs in advance to use foreach

# terraform apply -target module.parameter -target module.policy
# terraform apply -target module.role

variable "region" {
}
variable "access_key" {
}
variable "secret_key" {
}
variable "terraform_role" {
}

module "parameter" {
  source = "../parameter"

  region                    = var.region
  access_key                = var.access_key
  secret_key                = var.secret_key
  terraform_assume_role_arn = var.terraform_role

  parameter_name  = "/humanitec/example/parameter"
  parameter_value = "my value"

}

module "policy" {
  source = "../policy"

  region                    = var.region
  access_key                = var.access_key
  secret_key                = var.secret_key
  terraform_assume_role_arn = var.terraform_role

  policy_ssm_name = "humanitec-ssm-example-policy"
  parameter_arn   = module.parameter.parameter_arn
}

module "role" {
  source = "../role"

  region                    = var.region
  access_key                = var.access_key
  secret_key                = var.secret_key
  terraform_assume_role_arn = var.terraform_role

  role_name = "humanitec-eks-example-role"
  policies  = [module.policy.policy_ssm_arn]

  # below are parameters specific to a cluster,service account and namespace
  # they are not needed unless this is actually used by a cluster, for
  # testing you can use dummy values as below

  cluster_oidc    = "EXAMPLE"
  namespace       = "*"
  service_account = "*"
}

output "role" {
  value = module.role.role_arn
}
