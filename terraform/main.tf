################################
#                              #
#        NETWORK SETUP         #
#                              #
################################

resource "null_resource" "network_setup" {
  # connection {
  #   type        = "ssh"
  #   host        = var.proxmox_host_ip
  #   user        = "root"
  #   private_key = file("/Users/bacci/Repos/ANT-net/ssh/proxmox_id_rsa")
  # }

  # provisioner "file" {
  #   source      = "../scripts/network_setup.sh"  # Path to the script on your local machine
  #   destination = "/tmp/network_setup.sh"         # Path on the Proxmox hypervisor
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /tmp/network_setup.sh",  # Make the script executable
  #     "bash /tmp/network_setup.sh"        # Execute the script
  #   ]
  # }
}


################################
#                              #
#         VM TEMPLATE          #
#                              #
################################

resource "null_resource" "download_patch_cloud_init" {
  # depends_on = [ null_resource.network_setup ]
  # provisioner "local-exec" {
  #   command = "ssh -i ../ssh/proxmox_id_rsa root@10.79.5.250 'bash -s' < ../scripts/cloud-init-template.sh"
  # }
}

# module "vm_template" {
#   depends_on = [ null_resource.download_patch_cloud_init, null_resource.network_setup ]
#   source = "./modules/vm-template"
#   proxmox_host = var.proxmox_host
#   proxmox_host_ip = var.proxmox_host_ip
# }


################################
#                              #
#          VM MODULES          #
#                              #
################################

################################
#         VPN GATEWAY          #
################################

module "vpn_gateway" {
  # depends_on = [ module.vm_template ]
  source = "./modules/vm"
  vm_name = "VPN-gateway"
  vm_id = 110
  clone_id = 9000
  vm_ip = "10.10.10.10/24"
  proxmox_host = var.proxmox_host
  tags = ["terraform", "networking"]
}

resource "null_resource" "exec_vpn_gateway" {
  # depends_on = [ module.vpn_gateway ]
  provisioner "local-exec" {
    command = "ssh -i ../ssh/proxmox_id_rsa root@10.79.5.250 'bash -s' < ../scripts/vm_configuration/vpn_gateway.sh"
  }
}

################################
#         MQTT BROKER          #
################################

module "mqtt_broker" {
  # depends_on = [ module.vm_template ]
  source = "./modules/vm"
  vm_name = "MQTT-broker"
  vm_id = 111
  clone_id = 9000
  vm_ip = "10.10.10.11/24"
  proxmox_host = var.proxmox_host
  tags = ["terraform", "server"]
}

resource "null_resource" "exec_mqtt_broker" {
  depends_on = [ module.mqtt_broker ]
  provisioner "local-exec" {
    command = "ssh -i ../ssh/proxmox_id_rsa root@10.79.5.250 'bash -s' < ../scripts/vm_configuration/mqtt_broker.sh"
  }
}

################################
#         CoAP SERVER          #
################################

module "coap_server" {
  # depends_on = [ module.vm_template ]
  source = "./modules/vm"
  vm_name = "CoAP-server"
  vm_id = 112
  clone_id = 9000
  vm_ip = "10.10.10.12/24"
  proxmox_host = var.proxmox_host
  tags = ["terraform", "server"]
}

resource "null_resource" "exec_coap_server" {
  depends_on = [ module.coap_server ]
  provisioner "local-exec" {
    command = "ssh -i ../ssh/proxmox_id_rsa root@10.79.5.250 'bash -s' < ../scripts/vm_configuration/coap_server.sh"
  }
}

################################
#         FILE SERVER          #
################################

module "file_server" {
  # depends_on = [ module.vm_template ]
  source = "./modules/vm"
  vm_name = "File-server"
  vm_id = 113
  clone_id = 9000
  vm_ip = "10.10.10.13/24"
  proxmox_host = var.proxmox_host
  tags = ["terraform", "server"]
}


################################
#                              #
#          FIREWALL            #
#                              #
################################

################################
#       NETWORK ALIASES        #
################################

# module "firewall_alias_wildcard" {
#   depends_on = [ null_resource.network_setup ]
#   source = "./modules/firewall_aliases"
#   alias_name = "wildcard"
#   alias_cidr = "0.0.0.0/0"
#   alias_comment = "Wildcard"
# }

# module "firewall_alias_gateway" {
#   depends_on = [ null_resource.network_setup ]
#   source = "./modules/firewall_aliases"
#   alias_name = "gateway"
#   alias_cidr = "10.10.10.1"
#   alias_comment = "Gateway"
# }

# module "firewall_alias_labvnet" {
#   depends_on = [ null_resource.network_setup ]
#   source = "./modules/firewall_aliases"
#   alias_name = "labvnet"
#   alias_cidr = "10.10.10.0/24"
#   alias_comment = "Lab Virtual Network"
# }

# module "lab_net_firewall" {
#   depends_on = [ null_resource.network_setup ]
#   source = "./modules/firewall"
#   security_group_name = "labvnet"
#   comment = "Laboratory Network Segment"
# }

# ################################
# #        FIREWALL RULES        #
# ################################

# module "vpn_firewall_options" {
#   source = "./modules/firewall_options"
#   proxmox_host = var.proxmox_host
#   vm_id = 110
#   security_group_name = "vpn-firewall"
#   comment = "VPN Gateway Firewall Options"
#   depends_on = [ module.vpn_gateway, module.lab_net_firewall ]
# }

# module "mqtt_firewall_options" {
#   source = "./modules/firewall_options"
#   proxmox_host = var.proxmox_host
#   vm_id = 111
#   security_group_name = "labvnet"
#   comment = "MQTT Broker Firewall Options"
#   depends_on = [ module.mqtt_broker, module.lab_net_firewall ]
# }

# module "coap_firewall_options" {
#   source = "./modules/firewall_options"
#   proxmox_host = var.proxmox_host
#   vm_id = 112
#   security_group_name = "labvnet"
#   comment = "CoAP Broker Firewall Options"
#   depends_on = [ module.coap_server, module.lab_net_firewall ]
# }

# module "file_firewall_options" {
#   source = "./modules/firewall_options"
#   proxmox_host = var.proxmox_host
#   vm_id = 113
#   security_group_name = "labvnet"
#   comment = "File Server Firewall Options"
#   depends_on = [ module.file_server, module.lab_net_firewall ]
# }
