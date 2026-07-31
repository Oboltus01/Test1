variable "workspace_suffix" {
  type        = map(string)
  description = "A map of suffixes to assign to the resources."
  default = {
    "default" = "default"
    "dev"     = "development"
    "prod"    = "production"
  }
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources."
  default = {
    "owner"       = "demo owner",
    "environment" = "demo"
  }

}

variable "vm_name" {
  description = "Name of the Linux virtual machine."
  type        = string
  default     = "vm"
}

variable "vm_name_provisioner" {
  description = "Name of the Linux virtual machine."
  type        = string
  default     = "vm-provisioner"
}

variable "vm_size" {
  description = "Azure VM size."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for SSH access."
  type        = string
  default     = "azureuser"
}

variable "image_tag" {
  description = "Tag of the Docker image to deploy."
  type        = string
  default     = "latest"
}