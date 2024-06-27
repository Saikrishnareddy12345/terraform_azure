resource "azurerm_resource_group" "sai_rg" {
  name     = "sai-rg"
  location = "centralindia"
}

resource "azurerm_virtual_network" "sai_network" {
  name                = "sai-vpc"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sai_rg.location
  resource_group_name = azurerm_resource_group.sai_rg.name
}

resource "azurerm_subnet" "sai_subnet" {
  name                 = "sai-sub"
  resource_group_name  = azurerm_resource_group.sai_rg.name
  virtual_network_name = azurerm_virtual_network.sai_network.name
  address_prefixes     = ["10.0.0.0/24"]
}
# Define a route table
resource "azurerm_route_table" "sai_route_table" {
  name                = "sai-route-table"
  resource_group_name = azurerm_resource_group.sai_rg.name
  location            = azurerm_resource_group.sai_rg.location
}
# Define a route in the route table
resource "azurerm_route" "sai_route" {
  name                = "sai-route"
  resource_group_name = azurerm_resource_group.sai_rg.name
  route_table_name    = azurerm_route_table.sai_route_table.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}
# Associate the route table with the subnet

resource "azurerm_subnet_route_table_association" "sai_association" {
  subnet_id      = azurerm_subnet.sai_subnet.id
  route_table_id = azurerm_route_table.sai_route_table.id
}
# Define a public IP address
resource "azurerm_public_ip" "sai_public_ip" {
  name                = "sai_public_ip"
  location            = azurerm_resource_group.sai_rg.location
  resource_group_name = azurerm_resource_group.sai_rg.name
  allocation_method   = "Dynamic"
}
# Define a network interface
resource "azurerm_network_interface" "sai_ni" {
  name                = "sai-ni"
  resource_group_name = azurerm_resource_group.sai_rg.name
  location            = azurerm_resource_group.sai_rg.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sai_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sai_public_ip.id
    # network_security_group_id     = azurerm_network_security_group.sai_nsg.id
  }
}


# Associate the NSG with the network interface
resource "azurerm_network_interface_security_group_association" "sai_nsg_interface_association" {
  network_interface_id      = azurerm_network_interface.sai_ni.id
  network_security_group_id = azurerm_network_security_group.sai_nsg.id
}
# Define the virtual machine

resource "azurerm_virtual_machine" "sai_vm" {
  name                  = "sai-vm"
  location              = azurerm_resource_group.sai_rg.location
  resource_group_name   = azurerm_resource_group.sai_rg.name
  network_interface_ids = [azurerm_network_interface.sai_ni.id]
  vm_size               = "Standard_DS1_v2"
  # Storage settings
  storage_os_disk {
    name              = "sai-storage"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 20
  }
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_profile {
    computer_name  = "sai-vm1"
    admin_username = "saikrish"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/saikrish/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCz3ROx3NlxjjLz8BCB2zLpqzAREvLT2XkWMkqQb60i9kSg3TZvLiZSO9hTLDf+HXXnhmaSkeztjGcfpceYbpns4s+KycFg36C39A8LbYq59adrSCudK5PzY8PuMh7zrHe64WaKGHUBU0zmhLeBzrpdQglcd/UR0ueGTqZlCQNdUUQHWYAgXkXdHCx0gpjujIz8vF12XGsF6I46VUXw3fQnEfYrYTWSj4Cr7hbT9qe1mkTEL8XDRy5nlSoGJij4+EM3mxdHobCYB3XtdaNC5Qj48eu5x6YLweDw8vtTC4S1PPWf1sks95ENY8BkzXKWMRs3YLM7sMFIKKEk3P4qCh/gLwZ/q4xiur2YwZ1UOgOOAgRBjoyrocbFhgb53Ne+SzIj+B6wDEGwDA8FkspngA38q0ilYTwUpj68oaWPSLtxqqyGQAkjNUhVIR6A9XXuzUo0aBXmQvfXICx7XRDWEHhhn2i78cRllrpmVeL9JKgu5JO4YuU48nxaEWKI5th7LC0= SAI PRATAP@DESKTOP-K0BHALG"
    }
  }
  tags = {
    Name        = "sai-vm1"
    environment = "dev"
  }
}
# Define a Network Security Group (NSG)
resource "azurerm_network_security_group" "sai_nsg" {
  name                = "sai-nsg"
  location            = azurerm_resource_group.sai_rg.location
  resource_group_name = azurerm_resource_group.sai_rg.name
  security_rule {
    name                   = "allow-ssh"
    priority               = 1001
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "22"
    # source_prefix_address      = "*"
    # destination_prefix_address = "*"
  }

  security_rule {
    name                   = "allow-http"
    priority               = 1002
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "80"
    # source_prefix_address      = "*"
    # destination_prefix_address = "*"
  }

  security_rule {
    name                   = "allow-https"
    priority               = 1003
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "443"
    # source_prefix_address      = "*"
    # destination_prefix_address = "*"
  }
}
# # Associate the NSG with the subnet
# resource "azurerm_subnet_network_security_group_association" "sai_nsg_association" {

# }not needed, i can attach the NSG to the network_interface directy
