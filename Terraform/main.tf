terraform {
   required_version = ">= 0.12"
   required_providers {
      azurerm = "~>2.24.0"
   
   }
}


provider "azurerm" {
   subscription_id = "b86829c3-25e9-4a83-b961-836bb4549473"
   client_id = "b8864c95-6814-4765-8039-2349b8ece31b"
   client_secret = "RUa8Q~zfImLlcJOvOYQdaYJI.CMzho1sq-zDLbca"
   tenant_id = "ab823e41-9aa7-4644-807b-6f215795a229"
   features {}
}


resource "azurerm_resource_group" "nginx-webserver" {
   name = "nginx-webserver"
   location = "North Europe"
}

resource "azurerm_dns_zone" "cgiautomationchallengecgicom" {
name                = "cgi-automation-challenge.cgi.com"
resource_group_name = "nginx-webserver"
}

resource "azurerm_dns_a_record" "cgiproject" {
name                = "cgi"
zone_name           = "North Europe"
resource_group_name = "nginx-webserver"
ttl                 = 300
records             = ["127.0.0.1"]
}

resource "azurerm_network_security_group" "allowedports" {
   name = "allowedports"
   resource_group_name = "nginx-webserver"
   location = "North Europe"
  
   security_rule {
       name = "http"
       priority = 100
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "80"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }

   security_rule {
       name = "https"
       priority = 200
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "443"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }

   security_rule {
       name = "ssh"
       priority = 300
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "22"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }
}
resource "azurerm_public_ip" "webserver_public_ip" {
   name = "webserver_public_ip"
   location = "North Europe"
   resource_group_name = "nginx-webserver"
   allocation_method = "Dynamic"

   tags = {
       environment = "dev"
       costcenter = "it"
   }

   depends_on = [azurerm_resource_group.webserver]
}

resource "azurerm_network_interface" "webserver" {
   name = "nginx-interface"
   location = "North Europe"
   resource_group_name = "nginx-webserver"

   ip_configuration {
       name = "internal"
       private_ip_address_allocation = "Dynamic"
       subnet_id = module.network.vnet_subnets[0]
       public_ip_address_id = azurerm_public_ip.webserver_public_ip.id
   }

   depends_on = [azurerm_resource_group.webserver]
}


resource "azurerm_container_group" "cgitest" {
  name                = "cgiserver"
  location            = "North Europe"
  resource_group_name = "webserver"
  ip_address_type     = "Public"
  dns_name_label      = "cgiproject"
  os_type             = "Linux"

  container {
    name   = "hello-cgi"
    image  = "cgireg.azurecr.io/anaters/cgi-image:v1"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 443
      protocol = "TCP"
    }
  }

  tags = {
    environment = "cgitest"
  }
}

