# Static configuration

# ## Azure config
# variable "rg_name" {
#   type = string
# }
# variable "storage_account_name" {
#   type = string
# }
# variable "container_name" {
#   type = string
# }
# variable "key_prefix" {
#   type = string
#   default = ""
# }
# variable "key_vault_name" {
#   type = string
# }
# variable "key_vault_rg" {
#   type = string
# }

# Generic
variable "uuid" {
  type = string
}

# Azure DevOps (ADO)
variable "ado_org" {
  type = string
}
variable "ado_user" {
  type = string
}
variable "ado_pat" {
  type = string
}
# variable "ado_org_pat_suffix" {
#   type = string
#   default = "-PAT"
# }

# Azure DevOps Project configuration
variable "project_name" {
  type = string
}

variable "version_control" {
  type = string
}

variable "work_item_template" {
  type = string
}

variable "description" {
  type = string
}

# User Assignments
variable "users" {
  type = list(object({
    meshIdentifier = string
    username       = string
    firstName      = string
    lastName       = string
    email          = string
    euid           = string
    roles          = list(string)
  }))
}