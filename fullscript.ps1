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
Import-Module Az.Automation

# Get the existing virtual network and subnet
$virtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $virtualNetwork

# Retrieve VM credentials from Automation Account
$credDjango = Get-AutomationPSCredential -Name 'DjangoCredential'
$credDC = Get-AutomationPSCredential -Name 'DCCredential'

# Debug output to check credentials
Write-Host "Retrieved credentials for Django and DC VMs."

# Initialize and create Django VM
$djangoVmConfig = New-AzVMConfig -VMName $DjangoVMName -VMSize $DjangoVMSize
$djangoVmConfig = Set-AzVMOperatingSystem -VM $djangoVmConfig -Linux -ComputerName $DjangoVMName -Credential $credDjango
$djangoVmConfig = Set-AzVMSourceImage -VM $djangoVmConfig -PublisherName $DjangoPublisherName -Offer $DjangoOffer -Skus $DjangoSku -Version 'latest'
$nicDjango = New-AzNetworkInterface -Name "djangoVMNIC" -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $subnet.Id
$djangoVmConfig = Add-AzVMNetworkInterface -VM $djangoVmConfig -Id $nicDjango.Id
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $djangoVmConfig

# Initialize and create DC VM
$dcVmConfig = New-AzVMConfig -VMName $DCVMName -VMSize $DCVMSize
$dcVmConfig = Set-AzVMOperatingSystem -VM $dcVmConfig -Windows -ComputerName $DCVMName -Credential $credDC
$dcVmConfig = Set-AzVMSourceImage -VM $dcVmConfig -PublisherName $DCPublisherName -Offer $DCOffer -Skus $DCSku -Version 'latest'
$nicDC = New-AzNetworkInterface -Name "DCVMNIC" -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $subnet.Id
$dcVmConfig = Add-AzVMNetworkInterface -VM $dcVmConfig -Id $nicDC.Id
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $dcVmConfig

