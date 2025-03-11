terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
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
    when = "create"
    command = <<EOT
      # Cleanup file if it exists
      rm devices.txt

      # POST Request and safe answer
      RESPONSE=$(curl -X POST ${var.nautobot_link}/api/dcim/devices/ \
        -H "Authorization: Token ${var.nautobot_token}" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "${each.key}",  
            "device_type": "6301cd13-9161-44de-a88e-7a5a2cc0d6b8", 
            "role": "e0b23d77-fbfa-4106-8e03-09fd00d7dfc8", 
            "location": "ac0506d2-1ddb-4175-8382-2fb3cbf78f73",
            "status": "023e4472-398a-4351-a82f-743e69085cc3", 
            "comments": "Automatically generated through Tofu on GCP. IP: ${each.value.network_interface[0].access_config[0].nat_ip}"
        }')
      
      # extract DEVICE_ID
      DEVICE_ID=$(echo $RESPONSE | jq -r '.id')

      echo "${each.key}: $DEVICE_ID" >> devices.txt
    EOT
  }
  depends_on = [google_compute_instance.vm_instances]
}
