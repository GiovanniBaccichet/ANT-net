output "vpn_gateway_password" {
  value     = module.vpn_gateway.generated_password
  sensitive = true
}

output "mqtt_broker_password" {
  value     = module.mqtt_broker.generated_password
  sensitive = true
}

output "coap_server_password" {
  value     = module.coap_server.generated_password
  sensitive = true
}

output "file_server_password" {
  value     = module.file_server.generated_password
  sensitive = true
}