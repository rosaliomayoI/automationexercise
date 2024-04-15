# Create a Virtual Network
$virtualNetwork = New-AzVirtualNetwork `
  -ResourceGroupName "rosalio-onboarding" `
  -Location "East US" `
  -Name "vnet01" `
  -AddressPrefix "10.0.0.0/16"

# Add a Subnet
$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
  -Name "subnet01" `
  -AddressPrefix "10.0.0.0/24" `
  -VirtualNetwork $virtualNetwork

# Set the Virtual Network
$virtualNetwork | Set-AzVirtualNetwork
