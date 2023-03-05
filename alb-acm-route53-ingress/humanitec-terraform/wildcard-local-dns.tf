variable "dns_local_resource_name" {}
variable "dns_local_domain" {}

resource "humanitec_resource_definition" "dns_local" {
  id          = var.dns_local_resource_name
  name        = var.dns_local_resource_name
  type        = "dns"
  driver_type = "humanitec/template"

  driver_inputs = {
    values = {

      templates = jsonencode({
        init      = <<EOL
D: ".${var.dns_local_domain}"
S: {{ trimSuffix ".externals.${var.dns_local_resource_name}" "$${context.res.id}" }}
EOL
        manifests = ""
        outputs   = <<EOL
host: $${context.app.id}-{{ trimPrefix "modules." .init.S }}-$${context.env.id}{{.init.D}}
EOL
        cookie    = ""
      })
    }
    secrets = {
    }
  }

  # this should be dynamic
  criteria = [
    {
      app_id = humanitec_application.app.id
      res_id = "modules.backend.externals.${var.dns_local_resource_name}"
    },
    {
      app_id = humanitec_application.app.id
      res_id = "modules.frontend.externals.${var.dns_local_resource_name}"
    }
  ]
}
