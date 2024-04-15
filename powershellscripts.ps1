# Variables
$resourceGroupName = 'rosalio-onboarding'
$location = 'East US'
$vmName = 'DCVM'
$vmSize = 'Standard_DS1_v2'
$vnetName = 'vnet01'
$subnetName = 'subnet01'
$publicIpAddressName = 'DCPublicIP'
$networkSecurityGroupName = 'DCNSG'
$adminUsername = 'fox'
$adminPassword = 'Rmi9306021998@'
$dcScriptUrl = 'https://raw.githubusercontent.com/rosaliomayoI/automationexercise/main/promotetodc.ps1'
$subscriptionId = '62dbf7f9-1f0d-419d-9ac1-64330a42a648'  # Your actual subscription ID

# Create a public IP address
$pip = New-AzPublicIpAddress -Name $publicIpAddressName -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Static

# Create a network security group with the valid IP address for RDP
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name 'DefaultAllowRDP' -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix '65.140.106.2' -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange 3389 -Access Allow
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name $networkSecurityGroupName -SecurityRules $nsgRuleRDP

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzNetworkInterface -Name "$vmName-NIC" -ResourceGroupName $resourceGroupName -Location $location -SubnetId "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/virtualNetworks/$vnetName/subnets/$subnetName" -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize |
            Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential (Get-Credential) |
            Set-AzVMSourceImage -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter' -Version 'latest' |
            Add-AzVMNetworkInterface -Id $nic.Id

# Create the virtual machine
$vm = New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

# Apply the Custom Script Extension to run the domain controller promotion script
Set-AzVMCustomScriptExtension -ResourceGroupName $resourceGroupName -VMName $vmName -Location $location -Name "SetupDomainController" -FileUri $dcScriptUrl -Run "promotetodc.ps1"
