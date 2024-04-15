# Windows domain VM and promotion to domain controller

# Variables
$resourceGroupName = "rosalio-onboarding"
$location = "East US"
$vmName = "WinDC"
$vnetName = "vnet01"
$subnetName = "subnet01"
$publicIpName = "$vmName-PublicIP"
$nicName = "$vmName-NIC"
$domainName = "rosalio-local.com"
$keyVaultName = "rosalio-keyvault"

# Retrieve Secure Credentials from Azure Key Vault
$secretName = "foxsecret"
$kvSecret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName
$securePassword = ConvertTo-SecureString -String $kvSecret.SecretValueText -AsPlainText -Force

# Network and IP Configuration
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
$pip = New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Static
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $location -SubnetId $subnet.Id -PublicIpAddressId $pip.Id

# VM Config
$cred = New-Object System.Management.Automation.PSCredential ("Administrator", $securePassword)
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_DS1_v2"
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
$osDiskName = "$vmName-OSDisk"
$vmConfig = Set-AzVMOSDisk -VM $vmConfig -Name $osDiskName -CreateOption FromImage -StorageAccountType "Standard_LRS"

# Create the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

# Install AD DS Role and Promote to Domain Controller
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSForest -DomainName $domainName -SafeModeAdministratorPassword $securePassword -Force -NoRebootOnCompletion -Confirm:$false -CreateDnsDelegation:$false


