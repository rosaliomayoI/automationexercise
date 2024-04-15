
# Variables
$resourceGroupName = "rosalio-onboarding"
$location = "East US"
$vmName = "LinuxDjangoVM"
$vnetName = "vnet01"
$subnetName = "subnet01"
$publicIpName = "$vmName-PublicIP"
$nicName = "$vmName-NIC"
$adminUsername = "adminuser"
$sshPublicKeyPath = "/path/to/publickey.pub"

# Network and IP Configuration
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
$pip = New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Static
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $location -SubnetId $subnet.Id -PublicIpAddressId $pip.Id

# VM Config
$sshPublicKey = Get-Content $sshPublicKeyPath
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_DS1_v2"
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vmName -Credential (New-Object System.Management.Automation.PSCredential ($adminUsername, ($sshPublicKey | ConvertTo-SecureString -AsPlainText -Force)))
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version "latest"
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
$osDiskName = "$vmName-OSDisk"
$vmConfig = Set-AzVMOSDisk -VM $vmConfig -Name $osDiskName -CreateOption FromImage -StorageAccountType "Standard_LRS"

# Custom Script Extension to Install Django
$customScriptSettings = @{
    "fileUris" = ["https://raw.githubusercontent.com/rosaliomayoI/automationexercise/main/installdjango.sh"]
    "commandToExecute" = "bash installdjango.sh"
}
Set-AzVMExtension -ResourceGroupName $resourceGroupName -VMName $vmName -Name "CustomScriptForLinux" -Publisher "Microsoft.Azure.Extensions" -ExtensionType "CustomScript" -TypeHandlerVersion "2.1" -Settings $customScriptSettings -Location $location

# Create the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig
