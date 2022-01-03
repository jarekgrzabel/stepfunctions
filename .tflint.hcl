# https://github.com/terraform-linters/tflint/blob/master/docs/guides/config.md

config {
  module     = false
  force      = false
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = false
}
