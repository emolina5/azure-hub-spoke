variable "location" {
  type        = string
  default     = "North Europe"
  description = "The Azure Region where the Resource Group should exist. Changing this forces a new Resource Group to be created."
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "The environment name used for resource naming and separation (e.g., dev, test, prod). Changing this may affect resource naming and deployments."
}
