variable "subscription_id" {
  type        = string
  default     = ""
  description = "Subscription ID for Azure Service Principal to connect to"
}

variable "client_id" {
  type        = string
  default     = ""
  description = "Client ID of Azure Service Principal connection"
}

variable "client_secret" {
  type        = string
  default     = ""
  description = "Client Secret of Azure Service Principal connection"
}

variable "tenant_id" {
  type        = string
  default     = ""
  description = "Tenant ID of Azure Service Principal connection"
}

variable "rg_name" {
  type        = string
  default     = "rg-tf-workshop"
  description = "Resource Group Name in Azure for workshop resources to be placed in"
}


variable "prefix" {
  type        = string
  default     = "tf-workshop"
  description = "Prefix for Azure resources"
}

variable "tags" {
  type = map(string)
  default = {
    Application     = "TERRAFORM-WORKSHOP"
    CreatedBy       = "Your.Email@domain.eu"
    Department      = "Cloud Services"
    EnvironmentType = "Dev"
  }
}
