provider "azurerm" {
  version         = "1.44.0"
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

resource "azurerm_app_service_plan" "asp" {
  name                = "${var.prefix}-asp"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true
  tags                = var.tags

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "production" {
  name                = "${var.prefix}-appservice"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id
  tags                = var.tags

  site_config {
    app_command_line = ""
    linux_fx_version = "DOCKER|nilsas/tf-go-docker:71"
  }

  app_settings = {
    "DEPLOYMENT_SLOT" = "Production"
  }
}

resource "azurerm_app_service_slot" "staging" {
  name                = "staging"
  app_service_name    = azurerm_app_service.production.name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id
  tags                = var.tags

  site_config {
    linux_fx_version = "DOCKER|nilsas/tf-go-docker:71"
  }

  app_settings = {
    "DEPLOYMENT_SLOT" = "Staging"
  }
}

resource "azurerm_app_service_active_slot" "activeslot" {
  resource_group_name   = data.azurerm_resource_group.rg.name
  app_service_name      = azurerm_app_service.production.name
  app_service_slot_name = azurerm_app_service_slot.staging.name
}