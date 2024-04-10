param(
    [string]$rgName,
    [string]$location,
    [string]$vnetName,
    [string]$subnetName,
    [string]$nsgName,
    [string]$rule4EgressIP,
    [string]$domainControllerVmName,
    [string]$djangoVmName,
    [string]$keyVaultName,
    [string]$domainName = "example.local"
)

# Retrieve credentials from Azure Key Vault for VM admin
$adminUsernameSecret = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name "adminUsername").SecretValueText
$adminPasswordSecret = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name "adminPassword").SecretValue
$adminPassword = $adminPasswordSecret | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($adminUsernameSecret, $adminPassword)

# Retrieve credentials from Azure Key Vault for Safe Mode (DSRM)
$dsrmPasswordSecret = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name "dsrmPassword").SecretValue
$dsrmPassword = $dsrmPasswordSecret | ConvertTo-SecureString -AsPlainText -Force

# Network configuration
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet

# Domain Controller VM configuration
$dcNic = New-AzNetworkInterface -Name "$domainControllerVmName-nic" -ResourceGroupName $rgName -Location $location -SubnetId $subnet.Id
$dcVmConfig = New-AzVMConfig -VMName $domainControllerVmName -VMSize "Standard_DS2_v2"
$dcVmConfig = Set-AzVMOperatingSystem -VM $dcVmConfig -Windows -ComputerName $domainControllerVmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$dcVmConfig = Set-AzVMSourceImage -VM $dcVmConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"
$dcVmConfig = Add-AzVMNetworkInterface -VM $dcVmConfig -Id $dcNic.Id
$dcVmConfig = Set-AzVMOSDisk -VM $dcVmConfig -CreateOption FromImage -DiskSizeInGB 128

# Deploy the Domain Controller VM
$dcVm = New-AzVM -ResourceGroupName $rgName -Location $location -VM $dcVmConfig

# Install AD DS role and promote to Domain Controller
Invoke-AzVMRunCommand -ResourceGroupName $rgName -VMName $domainControllerVmName -CommandId 'RunPowerShellScript' -ScriptPath '~/Desktop/scripts/installadds.ps1' -Parameter @{"safeModeAdministratorPassword"=$dsrmPassword}

# Django VM configuration (Ubuntu)
$djangoNic = New-AzNetworkInterface -Name "$djangoVmName-nic" -ResourceGroupName $rgName -Location $location -SubnetId $subnet.Id
$djangoVmConfig = New-AzVMConfig -VMName $djangoVmName -VMSize "Standard_DS2_v2"
$djangoVmConfig = Set-AzVMOperatingSystem -VM $djangoVmConfig -Linux -ComputerName $djangoVmName -Credential $cred -DisablePasswordAuthentication
$djangoVmConfig = Set-AzVMSourceImage -VM $djangoVmConfig -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version "latest"
$djangoVmConfig = Add-AzVMNetworkInterface -VM $djangoVmConfig -Id $djangoNic.Id
$djangoVmConfig = Set-AzVMOSDisk -VM $djangoVmConfig -CreateOption FromImage -DiskSizeInGB 128

# Deploy the Django VM
$djangoVm = New-AzVM -ResourceGroupName $rgName -Location $location -VM $djangoVmConfig

# Create NSG rule to allow inbound traffic from Rule4's egress IP (assuming HTTPS traffic on port 443)
$httpsRule = New-AzNetworkSecurityRuleConfig -Name "AllowHTTPSFromRule4EgressIP" -Description "Allow inbound HTTPS traffic from Rule4's egress IP" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority 100 -SourceAddressPrefix $rule4EgressIP -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 443

# Apply the NSG rule to the appropriate NSG (associated with the subnet)
Set-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName -SecurityRules $httpsRule

# Associate the NSG with the subnet containing the Django VM
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName -AddressPrefix "10.
