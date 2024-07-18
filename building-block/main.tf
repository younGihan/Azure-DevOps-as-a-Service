# Create baseAuth credentials
locals {
  base64_auth = nonsensitive(base64encode("${var.ado_user}:${var.ado_pat}"))
}

# ADO Part
resource "azuredevops_project" "devops_project" {
  name               = var.project_name
  visibility         = "private"
  version_control    = var.version_control
  work_item_template = var.work_item_template
  description        = var.description
  lifecycle {
    ignore_changes = [
      # ignore changes on the display name
      name
    ]
  }
}
# create limted ADO Project admin group
resource "azuredevops_group" "admin_group" {
  scope        = azuredevops_project.devops_project.id
  display_name = "Admin Group"
  description  = "DevOps Project Administrator Group"
}

resource "azuredevops_project_permissions" "admin_group_permission" {
  project_id = azuredevops_project.devops_project.id
  principal  = azuredevops_group.admin_group.id
  permissions = {
    DELETE = "Deny"
    RENAME = "Deny"
  }
}

# Get the default reader group for the project
data "azuredevops_group" "reader_group" {
  project_id = azuredevops_project.devops_project.id
  name       = "Readers"
}

# Get the default user group for the project
data "azuredevops_group" "user_group" {
  project_id = azuredevops_project.devops_project.id
  name       = "Contributors"
}

# iterate through the list of users and redue to a map of user with only their euid
locals {
  all_users    = { for user in var.users : user.euid => user }
  reader_users = { for user in var.users : user.euid => user if contains(user.roles, "reader") }
  admin_users  = { for user in var.users : user.euid => user if contains(user.roles, "admin") }
  user_users   = { for user in var.users : user.euid => user if contains(user.roles, "user") }
}

# create a list of exisiting users
data "azuredevops_users" "existing" {
  for_each = { for user in var.users : user.email => user }

  principal_name = each.value.email
}

locals {
  users_to_create = {
    for user in var.users :
    user.email => user if length(try(data.azuredevops_users.existing[user.email].users, [])) == 0
  }
}
output "users_to_create" {
  value = {for user in local.users_to_create : user.email => user.email}
}

# Assign Users via ADO REST API
resource "null_resource" "create_users" {
  for_each = local.users_to_create

  depends_on = [
    data.azuredevops_users.existing  # Ensure null_resource runs after this
  ]
  provisioner "local-exec" {
    command = <<EOF
# Create new User
echo "Creating entitlement for user: ${each.value.email}"
curl -s --location 'https://vsaex.dev.azure.com/${var.ado_org}/_apis/userentitlements?api-version=7.2-preview.4' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic ${local.base64_auth}' \
--data-raw '{
    "accessLevel": {
        "accountLicenseType": "stakeholder"
    },
    "user": {
        "principalName": "${each.value.email}",
        "subjectKind": "user"
    }
}' > status.json

# cat status.json
api_status=$(jq -r '.operationResult.isSuccess' status.json)
echo "User entitlement: $api_status"

  EOF
  }    
}

# Get now all users according to their permissions in ADO
data "azuredevops_users" "reader" {
  depends_on = [
    null_resource.create_users 
  ]
  for_each = local.reader_users

  principal_name = each.value.euid
}

data "azuredevops_users" "admin" {
  depends_on = [
    null_resource.create_users 
  ]
  for_each = local.admin_users

  principal_name = each.value.euid
}

data "azuredevops_users" "user" {
  depends_on = [
    null_resource.create_users 
  ]
  for_each = local.user_users

  principal_name = each.value.euid
}

# Assign Users to the specific Azure DevOps Groups
resource "azuredevops_group_membership" "admin_user_group_assignmnet" {
    depends_on = [azuredevops_group.admin_group]

  for_each = data.azuredevops_users.admin
  group = azuredevops_group.admin_group.id
  members = [
    tolist(each.value.users)[0].descriptor
  ]
}

resource "azuredevops_group_membership" "user_user_group_assignmnet" {
    depends_on = [data.azuredevops_group.user_group]

  for_each = data.azuredevops_users.user
  group = data.azuredevops_group.user_group.id
  members = [
    tolist(each.value.users)[0].descriptor
  ]
}

resource "azuredevops_group_membership" "reader_user_group_assignmnet" {
    depends_on = [data.azuredevops_group.reader_group]

  for_each = data.azuredevops_users.reader
  group = data.azuredevops_group.reader_group.id
  members = [
    tolist(each.value.users)[0].descriptor
  ]
}