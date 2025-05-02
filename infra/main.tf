provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Recurso: Grupo de recursos para Lab 3
resource "azurerm_resource_group" "erick_lab3_rg" {
  name     = "erick-lab3-rg"
  location = "westus2"
}

# Recurso: Servidor SQL para el laboratorio 3
resource "azurerm_mssql_server" "erick_sql_server" {
  name                         = "erick-lab3-sql"
  location                     = azurerm_resource_group.erick_lab3_rg.location
  resource_group_name          = azurerm_resource_group.erick_lab3_rg.name
  version                      = "12.0"
  administrator_login          = var.sqladmin_username
  administrator_login_password = var.sqladmin_password

  identity {
    type = "SystemAssigned"
  }
}

# Recurso: Base de datos principal
resource "azurerm_mssql_database" "erick_lab3_db" {
  name                         = "erick-lab3-db"
  server_id                    = azurerm_mssql_server.erick_sql_server.id
  sku_name                     = "Basic"
  collation                    = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb                  = 2
  zone_redundant               = false
  depends_on                   = [azurerm_mssql_server.erick_sql_server]
}

# Recurso: Regla de firewall para habilitar acceso general
resource "azurerm_mssql_firewall_rule" "erick_fw_rule" {
  name             = "AllowAllIPs"
  server_id        = azurerm_mssql_server.erick_sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
