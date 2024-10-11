
#Establish which Proxmox host you'd like to spin a VM up on
variable "proxmox_host" {
  default = "mr-potato"
}

#Provide the url of the host you would like the API to communicate on.
#It is safe to default to setting this as the URL for what you used
#as your `proxmox_host`, although they can be different
variable "api_url" {
  default = "https://10.79.5.250:8006/api2/json"
}

#Specify which template name you'd like to use
variable "template_name" {
  default = "ubuntu-2204-template"
}

#Blank var for use by terraform.tfvars
variable "api_token" {
}
