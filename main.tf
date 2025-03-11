terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      #version = "6.24.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "tofu-network"
}

resource "google_compute_instance" "vm_instances" {
  for_each     = toset(var.servers)
  name         = each.key
  machine_type = "e2-micro"
  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}

resource "null_resource" "send_to_nautobot" {
  for_each = google_compute_instance.vm_instances

  provisioner "local-exec" {
    when    = "create"
    command = <<EOT
      # POST Request and safe answer
      RESPONSE=$(curl -X POST ${var.nautobot_link}/api/dcim/devices/ \
        -H "Authorization: Token ${var.nautobot_token}" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "${each.key}",  
            "device_type": "${var.device_type_veos}", 
            "role": "${var.role_router}", 
            "location": "${var.location}",
            "status": "${var.status}", 
            "comments": "Automatically generated through Tofu on GCP. IP: ${each.value.network_interface[0].access_config[0].nat_ip}"
        }')
      
      # extract DEVICE_ID
      DEVICE_ID=$(echo $RESPONSE | jq -r '.id')

      echo "${each.key}:$DEVICE_ID" >> devices.txt
    EOT
  }
  depends_on = [google_compute_instance.vm_instances]
}


resource "null_resource" "destroy_device_in_nautobot" {
  triggers = {
    nautobot_link  = var.nautobot_link
    nautobot_token = var.nautobot_token
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = <<EOT
      while IFS=: read -r name id; do
        echo "Delete Device $name with ID $id"
        curl -X DELETE "${self.triggers.nautobot_link}/api/dcim/devices/$id/" \
             -H "Authorization: Token ${self.triggers.nautobot_token}"
      done < devices.txt

      rm devices.txt
    EOT
  }
}