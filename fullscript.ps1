# Create Virtual Network and Subnet
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name 'subnet01' -AddressPrefix '10.0.0.0/24'
$vnetParams = @{
    Name              = 'vnet01'
    ResourceGroupName = 'rosalio-onboarding'
    Location          = 'East US'
    AddressPrefix     = '10.0.0.0/16'
    Subnet            = $subnetConfig
}
$vnet = New-AzVirtualNetwork @vnetParams

# Parameters for the Domain Controller VM
$credDC = Get-Credential -Message "Enter username and password for the Domain Controller VM"
$vmParamsDC = @{
    VMName            = 'DCVM'
    VMSize            = 'Standard_D2s_v3'
    Windows           = $true
    Credential        = $credDC
    ResourceGroupName = 'rosalio-onboarding'
    Location          = 'East US'
    SubnetId          = $vnet.Subnets[0].Id
    ImageName         = 'Win2019Datacenter'
}
$dcVmConfig = New-AzVMConfig @vmParamsDC
$dcVmConfig = Set-AzVMOperatingSystem -VM $dcVmConfig -Windows -ComputerName $vmParamsDC.VMName -Credential $vmParamsDC.Credential
$dcVmConfig = Set-AzVMSourceImage -VM $dcVmConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"
$dcVmConfig = Add-AzVMNetworkInterface -VM $dcVmConfig -Id (New-AzNetworkInterface -Name "$($vmParamsDC.VMName)NIC" -ResourceGroupName $vmParamsDC.ResourceGroupName -Location $vmParamsDC.Location -SubnetId $vmParamsDC.SubnetId).Id
New-AzVM -ResourceGroupName $vmParamsDC.ResourceGroupName -Location $vmParamsDC.Location -VM $dcVmConfig

# Parameters for the Django VM
$credDjango = Get-Credential -Message "Enter username and password for the Django VM"
$vmParamsDjango = @{
    VMName            = 'djangoVM'
    VMSize            = 'Standard_D2s_v3'
    ResourceGroupName = 'rosalio-onboarding'
    Location          = 'East US'
    SubnetId          = $vnet.Subnets[0].Id
    PublisherName     = 'Canonical'
    Offer             = 'UbuntuServer'
    Skus              = '18_04-lts-gen2'
    Version           = 'latest'
    Credential        = $credDjango
}
$djangoVmConfig = New-AzVMConfig @vmParamsDjango
$djangoVmConfig = Set-AzVMOperatingSystem -VM $djangoVmConfig -Linux -ComputerName $vmParamsDjango.VMName -Credential $vmParamsDjango.Credential
$djangoVmConfig = Set-AzVMSourceImage -VM $djangoVmConfig -PublisherName $vmParamsDjango.PublisherName -Offer $vmParamsDjango.Offer -Skus $vmParamsDjango.Skus -Version $vmParamsDjango.Version
$djangoVmConfig = Add-AzVMNetworkInterface -VM $djangoVmConfig -Id (New-AzNetworkInterface -Name "$($vmParamsDjango.VMName)NIC" -ResourceGroupName $vmParamsDjango.ResourceGroupName -Location $vmParamsDjango.Location -SubnetId $vmParamsDjango.SubnetId).Id
New-AzVM -ResourceGroupName $vmParamsDjango.ResourceGroupName -Location $vmParamsDjango.Location -VM $djangoVmConfig
