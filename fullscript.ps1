

# Parameters
param (
    [string]$ResourceGroupName = 'rosalio-onboarding',
    [string]$Location = 'East US',
    [string]$VirtualNetworkName = 'vnet01',
    [string]$SubnetName = 'subnet01',
    [string]$DjangoVMName = 'djangoVM',
    [string]$DjangoVMSize = 'Standard_D2s_v3',
    [string]$DjangoPublisherName = 'Canonical',
    [string]$DjangoOffer = 'UbuntuServer',
    [string]$DjangoSku = '18_04-lts-gen2',
    [string]$DCVMName = 'DCVM',
    [string]$DCVMSize = 'Standard_D2s_v3',
    [string]$DCPublisherName = 'MicrosoftWindowsServer',
    [string]$DCOffer = 'WindowsServer',
    [string]$DCSku = '2019-Datacenter'
)

# Connect using device authentication
Connect-AzAccount -UseDeviceAuthentication

# Import necessary modules
Import-Module Az.Network
Import-Module Az.Compute
Import-Module Az.KeyVault

# Get the existing virtual network and subnet
$virtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $virtualNetwork

# Retrieve VM credentials for the Django VM from Azure Key Vault
$secretDjango = Get-AzKeyVaultSecret -VaultName 'rosalio-key' -Name 'djangoPassword'
if ($null -eq $secretDjango) {
    Write-Error "The Django password secret does not exist in the Key Vault."
} elseif ($null -eq $secretDjango.SecretValue) {
    Write-Error "The Django password secret is found but contains no data."
} else {
    $djangoPassword = ConvertTo-SecureString -String $secretDjango.SecretValue -AsPlainText -Force
    $credDjango = New-Object System.Management.Automation.PSCredential ('fox', $djangoPassword)

    # Debug output to check password
    Write-Host "Using password for Django VM."

    # Initialize VM configuration for Django
    $djangoVmConfig = New-AzVMConfig -VMName $DjangoVMName -VMSize $DjangoVMSize
    $djangoVmConfig = Set-AzVMOperatingSystem -VM $djangoVmConfig -Linux -ComputerName $DjangoVMName -Credential $credDjango
    $djangoVmConfig = Set-AzVMSourceImage -VM $djangoVmConfig -PublisherName $DjangoPublisherName -Offer $DjangoOffer -Skus $DjangoSku -Version 'latest'

    # Add a network interface configuration for Django VM
    $nicDjango = New-AzNetworkInterface -Name "djangoVMNIC" -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $subnet.Id
    $djangoVmConfig = Add-AzVMNetworkInterface -VM $djangoVmConfig -Id $nicDjango.Id

    # Create the Django VM
    New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $djangoVmConfig
}

# Retrieve VM credentials for the Domain Controller from Azure Key Vault
$secretDC = Get-AzKeyVaultSecret -VaultName 'rosalio-key' -Name 'dcPassword'
if ($null -eq $secretDC) {
    Write-Error "The DC password secret does not exist in the Key Vault."
} elseif ($null -eq $secretDC.SecretValue) {
    Write-Error "The DC password secret is found but contains no data."
} else {
    $dcPassword = ConvertTo-SecureString -String $secretDC.SecretValue -AsPlainText -Force
    $credDC = New-Object System.Management.Automation.PSCredential ('fox', $dcPassword)

    # Debug output to check password
    Write-Host "Using password for DC VM."

    # Initialize VM configuration for Domain Controller
    $dcVmConfig = New-AzVMConfig -VMName $DCVMName -VMSize $DCVMSize
    $dcVmConfig = Set-AzVMOperatingSystem -VM $dcVmConfig -Windows -ComputerName $DCVMName -Credential $credDC
    $dcVmConfig = Set-AzVMSourceImage -VM $dcVmConfig -PublisherName $DCPublisherName -Offer $DCOffer -Skus $DCSku -Version 'latest'

    # Add a network interface configuration for DC VM
    $nicDC = New-AzNetworkInterface -Name "DCVMNIC" -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $subnet.Id
    $dcVmConfig = Add-AzVMNetworkInterface -VM $dcVmConfig -Id $nicDC.Id

    # Create the Domain Controller VM
    New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $dcVmConfig
}
