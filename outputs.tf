output "ips" {
  description = "IPs of server"
  value = [
    for name, vm in google_compute_instance.vm_instances :
    {
      name        = name
      internal_ip = vm.network_interface[0].network_ip
      external_ip = vm.network_interface[0].access_config[0].nat_ip
      #device_id   = vm.metadata["device_id"]  # Die Device-ID aus den Metadaten
    }
  ]
}