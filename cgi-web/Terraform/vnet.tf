module "network" {
   source = "Azure/vnet/azurerm"
   version = "2.4.0"
   resource_group_name = "nginx-webserver"
   address_space = ["10.0.0.0/16"]
   subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24"]
   subnet_names = ["subnet1", "subnet2"]

   nsg_ids = {
       subnet1 = azurerm_network_security_group.allowedports.id
   }

   tags = {
       environment = "dev"
       costcenter = "it"
   }

   depends_on = [azurerm_resource_group.webserver]
}