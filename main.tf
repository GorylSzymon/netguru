resource "azurerm_resource_group" "ror" {
  name     = "rg-ror-prod"
  location = "West Europe"
}

resource "azurerm_storage_account" "data" {
  name                     = "sa-ror-prod"
  resource_group_name      = azurerm_resource_group.ror.name
  location                 = azurerm_resource_group.ror.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_app_service_plan" "primary" {
  name                = "app-plan-ror-prod"
  location            = azurerm_resource_group.ror.location
  resource_group_name = azurerm_resource_group.ror.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier     = "Standard"
    size     = "S1"
    capacity = 2
  }
}

resource "azurerm_app_service" "ror" {
  name                = "app-service-ror-prod"
  location            = azurerm_resource_group.ror.location
  resource_group_name = azurerm_resource_group.ror.name
  app_service_plan_id = azurerm_app_service_plan.primary.id

  site_config {
    ruby            = "2.6.2"
    scm_type        = "LocalGit"
    always_on       = true
    min_tls_version = "1.2"
  }
}

resource "azurerm_postgresql_server" "ror_db_server" {
  name                         = "postgresql-server-ror-1"
  location                     = azurerm_resource_group.ror.location
  resource_group_name          = azurerm_resource_group.ror.name
  sku_name                     = "B_Gen5_2"
  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "ror_db" {
  name                = "postgresql-db-ror-1"
  resource_group_name = azurerm_resource_group.ror.name
  server_name         = azurerm_postgresql_server.ror_db_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_redis_cache" "cache" {
  name                = "cache-ror"
  location            = azurerm_resource_group.ror.location
  resource_group_name = azurerm_resource_group.ror.name
  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
}
