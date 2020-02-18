#region Global Config

#Resource Group Creation
resource "azurerm_resource_group" "Techies-rg" {
  name = "Techies-rg"
  location = "eastasia"
  tags = {
    Owner = "Raveen Abeywickrama"
  }
}

#Virtual Network Creation
resource "azurerm_virtual_network" "Techies-vnet" {
  name                = "Techies-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.Techies-rg.location}"
  resource_group_name = "${azurerm_resource_group.Techies-rg.name}"
}

#endregion

##########################################################################

#region Webapp Configuration

#Service plan
resource "azurerm_app_service_plan" "Techies-sp" {
  name                = "Techies-sp"
  location            = "${azurerm_resource_group.Techies-rg.location}"
  resource_group_name = "${azurerm_resource_group.Techies-rg.name}"
  reserved = true 
  kind = "Linux"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

#App Service
resource "azurerm_app_service" "Techies-as" {
  name                = "Techies-as"
  location            = "${azurerm_resource_group.Techies-rg.location}"
  resource_group_name = "${azurerm_resource_group.Techies-rg.name}"
  app_service_plan_id = "${azurerm_app_service_plan.Techies-sp.id}"

  site_config {
    app_command_line = ""
    linux_fx_version = "DOCKER|ravianxreaver/testnodeapp"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://index.docker.io"
  }
}

#endregion

##############################################################################

#region MYSQL Server Configuration  

#Create MySQL Server
resource "azurerm_mysql_server" "Techies-mysql-server" {
  name                = "techies-mysql-serverx1"
  location            = "${azurerm_resource_group.Techies-rg.location}"
  resource_group_name = "${azurerm_resource_group.Techies-rg.name}"

  sku {
    name     = "B_Gen5_2"
    capacity = 1
    tier     = "Basic"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = "${var.mysql_user}"
  administrator_login_password = "${var.mysql_password}"
  version                      = "5.7"
  ssl_enforcement              = "Enabled"
}

#Subnet for mssql
resource "azurerm_subnet" "Techies-db" {
  name                 = "Techies-db-sub"
  resource_group_name  = "${azurerm_resource_group.Techies-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.Techies-vnet.name}"
  address_prefix       = "10.0.2.0/24"
  service_endpoints    = ["Microsoft.Sql"]
}

#Firewall Rule
resource "azurerm_mysql_firewall_rule" "Techies_mysql_firewall" {
  name                = "Techies_mysql_firewall"
  resource_group_name = "${azurerm_resource_group.Techies-rg.name}"
  server_name         = "${azurerm_mysql_server.Techies-mysql-server.name}"
  start_ip_address    = "10.0.2.20"
  end_ip_address      = "10.0.2.20"
}

#Virtual Network Rule
resource "azurerm_mysql_virtual_network_rule" "mysql-vnet-rule" {
  name                = "mysql-vnet-rule"
  resource_group_name = "${azurerm_resource_group.Techies-rg.name}"
  server_name         = "${azurerm_mysql_server.Techies-mysql-server.name}"
  subnet_id           = "${azurerm_subnet.Techies-db.id}"
}

#Public IP for Network Gateway
resource "azurerm_public_ip" "Techies-pivg" {
  name                = "Techies-pivg"
  location            = "${azurerm_resource_group.Techies-rg.location}"
  resource_group_name = "${azurerm_resource_group.Techies-rg.name}"

  allocation_method = "Dynamic"
}

resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = "${azurerm_resource_group.Techies-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.Techies-vnet.name}"
  address_prefix       = "10.0.1.0/24"
}

#Network gateway
resource "azurerm_virtual_network_gateway" "Techies-vng" {
  name                = "Techies-vng"
  location            = "${azurerm_resource_group.Techies-rg.location}"
  resource_group_name = "${azurerm_resource_group.Techies-rg.name}"

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = "${azurerm_public_ip.Techies-pivg.id}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${azurerm_subnet.GatewaySubnet.id}"
  }

  vpn_client_configuration {
    address_space = ["10.2.0.0/24"]

    root_certificate {
      name = "DigiCert-Federated-ID-Root-CA"

      public_cert_data = <<EOF
MIIDuzCCAqOgAwIBAgIQCHTZWCM+IlfFIRXIvyKSrjANBgkqhkiG9w0BAQsFADBn
MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
d3cuZGlnaWNlcnQuY29tMSYwJAYDVQQDEx1EaWdpQ2VydCBGZWRlcmF0ZWQgSUQg
Um9vdCBDQTAeFw0xMzAxMTUxMjAwMDBaFw0zMzAxMTUxMjAwMDBaMGcxCzAJBgNV
BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
Y2VydC5jb20xJjAkBgNVBAMTHURpZ2lDZXJ0IEZlZGVyYXRlZCBJRCBSb290IENB
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvAEB4pcCqnNNOWE6Ur5j
QPUH+1y1F9KdHTRSza6k5iDlXq1kGS1qAkuKtw9JsiNRrjltmFnzMZRBbX8Tlfl8
zAhBmb6dDduDGED01kBsTkgywYPxXVTKec0WxYEEF0oMn4wSYNl0lt2eJAKHXjNf
GTwiibdP8CUR2ghSM2sUTI8Nt1Omfc4SMHhGhYD64uJMbX98THQ/4LMGuYegou+d
GTiahfHtjn7AboSEknwAMJHCh5RlYZZ6B1O4QbKJ+34Q0eKgnI3X6Vc9u0zf6DH8
Dk+4zQDYRRTqTnVO3VT8jzqDlCRuNtq6YvryOWN74/dq8LQhUnXHvFyrsdMaE1X2
DwIDAQABo2MwYTAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAdBgNV
HQ4EFgQUGRdkFnbGt1EWjKwbUne+5OaZvRYwHwYDVR0jBBgwFoAUGRdkFnbGt1EW
jKwbUne+5OaZvRYwDQYJKoZIhvcNAQELBQADggEBAHcqsHkrjpESqfuVTRiptJfP
9JbdtWqRTmOf6uJi2c8YVqI6XlKXsD8C1dUUaaHKLUJzvKiazibVuBwMIT84AyqR
QELn3e0BtgEymEygMU569b01ZPxoFSnNXc7qDZBDef8WfqAV/sxkTi8L9BkmFYfL
uGLOhRJOFprPdoDIUBB+tmCl3oDcBy3vnUeOEioz8zAkprcb3GHwHAK+vHmmfgcn
WsfMLH4JCLa/tRYL+Rw/N3ybCkDp00s0WUZ+AoDywSl0Q/ZEnNY0MsFiw6LyIdbq
M/s/1JRtO3bDSzD9TazRVzn2oBqzSa8VgIo5C1nOnoAKJTlsClJKvIhnRlaLQqk=
EOF
}
    revoked_certificate {
    name       = "Verizon-Global-Root-CA"
    thumbprint = "912198EEF23DCAC40939312FEE97DD560BAE49B1"
    }
  }
}

#Create Database
resource "azurerm_mysql_database" "Techies_db" {
  name                = "Techies_db"
  resource_group_name = "${azurerm_resource_group.Techies-rg.name}"
  server_name         = "${azurerm_mysql_server.Techies-mysql-server.name}"
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
} 

#endregion