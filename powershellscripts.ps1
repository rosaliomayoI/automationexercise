#Setup and configuration using Powershell for the Azure Automation Exercise


#Create and configure the Virtual Network and Network Security Groups
# Variables
$vmNameDC = "foxDC"
$rgName = "rosalio-onboarding"
$location = "East US"
$vnetName = "foxhouseVNet"
$subnetName = "foxhouseSubnet"
$nsgName = "foxhouseNSG"


# Create and configure the Virtual Network and subnet

$rgName = "rosalio-onboarding"
$location = "East US"
$vnetName = "foxhouseVNet"
$subnetName = "foxhouseSubnet"
# Create Virtual Network and Subnet
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.0.1.0/24"
$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix "10.0.0.0/16" -Subnet $subnetConfig
$nsgName = "foxhouseNSG"
$ruleName = "AllowRule4Egress"
$rule4EgressIP = "65.140.106.2"  # Rule4's egress IP
# Create NSG and allow inbound rule for Rule4's egress IP
$nsg = New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName -Location $location
Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg -Name $ruleName -Priority 100 -Access Allow -Direction Inbound -Protocol Tcp -SourceAddressPrefix $rule4EgressIP -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "443"
$nsg | Set-AzNetworkSecurityGroup




#Deploy a windows server vm as the Domain Controller 

# Variables
$vmNameDC = "foxDC"
$rgName = "rosalio-onboarding"
$location = "East US"
$vnetName = "foxhouseVNet"
$subnetName = "foxhouseSubnet"
$nsgName = "foxhouseNSG"

#Create the windows VM
# Create a public IP with static allocation
$dcPip = New-AzPublicIpAddress -Name "$vmNameDC-pip" -ResourceGroupName $rgName -Location $location -AllocationMethod Static

# Fetch or create the virtual network and subnet
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
if (-not $vnet) {
    $vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix "10.0.0.0/16"
    $subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.0.1.0/24"
    $vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet.AddSubnet($subnetConfig)
}
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet

# Fetch or create the network security group
$nsg = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName
if (-not $nsg) {
    $nsg = New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName -Location $location
    $ruleName = "AllowRule4Egress"
    $rule4EgressIP = "65.140.106.2"
    $nsg = Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg -Name $ruleName -Priority 100 -Access Allow -Direction Inbound -Protocol Tcp -SourceAddressPrefix $rule4EgressIP -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "443"
    $nsg | Set-AzNetworkSecurityGroup
}

# Create a network interface for the VM
$dcNic = New-AzNetworkInterface -Name "$vmNameDC-nic" -ResourceGroupName $rgName -Location $location -SubnetId $subnet.Id -PublicIpAddressId $dcPip.Id -NetworkSecurityGroupId $nsg.Id

# VM configuration for Domain Controller
$vmConfigDC = New-AzVMConfig -VMName $vmNameDC -VMSize "Standard_DS2_v2"
$vmConfigDC = Set-AzVMOperatingSystem -VM $vmConfigDC -Windows -ComputerName $vmNameDC -Credential (Get-Credential) -ProvisionVMAgent -EnableAutoUpdate
$vmConfigDC = Set-AzVMSourceImage -VM $vmConfigDC -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"
$vmConfigDC = Add-AzVMNetworkInterface -VM $vmConfigDC -Id $dcNic.Id
$vmConfigDC = Set-AzVMOSDisk -VM $vmConfigDC -CreateOption FromImage -DiskSizeInGB 127
# Create the VM
New-AzVM -ResourceGroupName $rgName -Location $location -VM $vmConfigDC




# Script to deploy  Django App VM & Variables for Django App VM
# Variables (replace these with your actual values)
$rgName = "rosalio-onboarding"
$location = "East US"
$vmNameDC = "foxDC"
$vmNameDjango = "djangoVM"
$vnetName = "foxhouseVNET"
$subnetName = "foxhouseSubnet"
$nsgName = "foxhouseNSG"
$rule4EgressIP = "65.140.106.2"  # IP address to allow through NSG

# Create a public IP with static allocation for the Django VM
$djangoPip = New-AzPublicIpAddress -Name "$vmNameDjango-pip" -ResourceGroupName $rgName -Location $location -AllocationMethod Static

# Fetch or create the virtual network and subnet
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
if (-not $vnet) {
    $vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix "10.0.0.0/16"
    $subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.0.1.0/24"
    $vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet.AddSubnet($subnetConfig)
}
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet

# Fetch or create the network security group
$nsg = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName
if (-not $nsg) {
    $nsg = New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName -Location $location
    $nsg = Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg -Name "AllowRule4Egress" -Priority 100 -Access Allow -Direction Inbound -Protocol Tcp -SourceAddressPrefix $rule4EgressIP -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "443,8000"
    $nsg | Set-AzNetworkSecurityGroup
}

# Create a network interface for the Django VM
$djangoNic = New-AzNetworkInterface -Name "$vmNameDjango-nic" -ResourceGroupName $rgName -Location $location -SubnetId $subnet.Id -PublicIpAddressId $djangoPip.Id -NetworkSecurityGroupId $nsg.Id

# VM configuration for Django Linux VM
$vmConfigDjango = New-AzVMConfig -VMName $vmNameDjango -VMSize "Standard_DS2_v2"
$vmConfigDjango = Set-AzVMOperatingSystem -VM $vmConfigDjango -Linux -ComputerName $vmNameDjango -Credential (Get-Credential)
$vmConfigDjango = Set-AzVMSourceImage -VM $vmConfigDjango -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version "latest"
$vmConfigDjango = Add-AzVMNetworkInterface -VM $vmConfigDjango -Id $djangoNic.Id
$vmConfigDjango = Set-AzVMOSDisk -VM $vmConfigDjango -CreateOption FromImage -DiskSizeInGB 127

# Create the Django Linux VM
$vmDjango = New-AzVM -ResourceGroupName $rgName -Location $location -VM $vmConfigDjango

# Custom script extension to install and configure Django and integrate with Domain Controller
$customScriptSettings = @{
    "fileUris" = ["<URL to your Django and AD integration setup script>"]
    "commandToExecute" = "bash <name of your setup script>.sh"
}

Set-AzVMCustomScriptExtension -ResourceGroupName $rgName -VMName $vmNameDjango -Name "setupDjangoADIntegration" -Location $location -Setting $customScriptSettings






# Create a Key Vault
# Variables
$rgName = "rosalio-onboarding"  #resource group name
$location = "East US"  #location
$vaultName = "foxkeyvault222"  # Name for the Key Vault
$secretName = "foxesarecute"  # Name of the secret to store
$secretValue = "YourSecretPassword"  # The password or secret value you want to store

# Create or check for existing resource group
$resourceGroup = Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue
if (-not $resourceGroup) {
    New-AzResourceGroup -Name $rgName -Location $location
}

# Create the Key Vault
$vault = New-AzKeyVault -Name $vaultName -ResourceGroupName $rgName -Location $location -Sku Standard

# Store a secret in the Key Vault
$secureSecretValue = ConvertTo-SecureString $secretValue -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $vaultName -Name $secretName -SecretValue $secureSecretValue

# Output the details of the created Key Vault
Write-Output "Key Vault '$vaultName' created in resource group '$rgName'."
Write-Output "Secret '$secretName' added to Key Vault '$vaultName'."



