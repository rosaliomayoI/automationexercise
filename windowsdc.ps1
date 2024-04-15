
#Windows domain VM
# Variables
$resourceGroupName = "rosalio-onboarding"
$location = "East US"foc
$vmName = "WinDC"
$vnetName = "vnet01"
$subnetName = "subnet01"
$publicIpName = "$vmName-PublicIP"
$nicName = "$vmName-NIC"
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
$pip = New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Static
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $location -SubnetId $subnet.Id -PublicIpAddressId $pip.Id

# VM Config
$cred = Get-Credential -Message "Enter a username and password for the VM."
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_DS1_v2"
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
$osDiskName = "$vmName-OSDisk"
$vmConfig = Set-AzVMOSDisk -VM $vmConfig -Name $osDiskName -CreateOption FromImage -StorageAccountType "Standard_LRS"

# Output the VM configuration for debugging
Write-Output $vmConfig

# Create the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig
