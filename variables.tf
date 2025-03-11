variable "project" {}
variable "nautobot_link" {}
variable "nautobot_token" {}

variable "device_type_veos" {
  description = "Type of the Device: vEOS"
  type        = string
  default     = "6301cd13-9161-44de-a88e-7a5a2cc0d6b8"
}

variable "role_router" {
  description = "Role of the device: Router"
  type        = string
  default     = "e0b23d77-fbfa-4106-8e03-09fd00d7dfc8"
}


variable "location" {
  description = "City where the device resides: Boston"
  type        = string
  default     = "ac0506d2-1ddb-4175-8382-2fb3cbf78f73"
}

variable "status" {
  description = "Status of the device: Active"
  type        = string
  default     = "023e4472-398a-4351-a82f-743e69085cc3"
}

variable "region" {
  type = string
  default = "us-central1"
}

variable "zone" {
  type = string
  default = "us-central1-c"
}


variable "servers" {
  description = "List of names for the server"
  type        = list(string)
  default     = ["tofu-server1", "tofu-server2", "tofu-server3"]
}
