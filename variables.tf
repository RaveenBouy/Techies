provider "azurerm" {
    subscription_id = "${var.subscription_id}"
    client_id = "${var.client_id}"
    client_secret = "${var.client_secret}"
    tenant_id = "${var.tenant_id}"
}

variable "subscription_id" {
  description = "Subscription ID for provisioning resources"
}

variable "client_id" {
  description = "Client ID for application"
}

variable "client_secret" {
  description = "Client secret for application"
}

variable "tenant_id" {
  description = "ID for azure AD"
}

variable "mysql_user" {
  description = "Mysql master username"
}

variable "mysql_password" {
  description = "MySql Master password"
}
