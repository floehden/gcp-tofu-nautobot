variable "project" {}
variable "nautobot_link" {}
variable "nautobot_token" {}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}


variable "servers" {
  description = "List of names for the server"
  type        = list(string)
  default     = ["tofu-server1", "tofu-server2", "tofu-server3"]
}
