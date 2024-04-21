

# Get the existing virtual network and subnet
$virtualNetwork = Get-AzVirtualNetwork -Name 'vnet01' -ResourceGroupName 'rosalio-onboarding'
$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'subnet01' -VirtualNetwork $virtualNetwork

# Prompt for VM credentials for the Django VM
$credDjango = Get-Credential -Message "Enter username and password for the Django VM"

# Initialize VM configuration for Django
$djangoVmConfig = New-AzVMConfig -VMName 'djangoVM' -VMSize 'Standard_D2s_v3'
$djangoVmConfig = Set-AzVMOperatingSystem -VM $djangoVmConfig -Linux -ComputerName 'djangoVM' -Credential $credDjango
$djangoVmConfig = Set-AzVMSourceImage -VM $djangoVmConfig -PublisherName 'Canonical' -Offer 'UbuntuServer' -Skus '18_04-lts-gen2' -Version 'latest'

# Add a network interface configuration for Django VM
$nicDjango = New-AzNetworkInterface -Name "djangoVMNIC" -ResourceGroupName 'rosalio-onboarding' -Location 'East US' -SubnetId $subnet.Id
$djangoVmConfig = Add-AzVMNetworkInterface -VM $djangoVmConfig -Id $nicDjango.Id

# Create the Django VM
New-AzVM -ResourceGroupName 'rosalio-onboarding' -Location 'East US' -VM $djangoVmConfig

# Prompt for VM credentials for the Domain Controller VM
$credDC = Get-Credential -Message "Enter username and password for the Domain Controller VM"

# Initialize VM configuration for Domain Controller
$dcVmConfig = New-AzVMConfig -VMName 'DCVM' -VMSize 'Standard_D2s_v3'
$dcVmConfig = Set-AzVMOperatingSystem -VM $dcVmConfig -Windows -ComputerName 'DCVM' -Credential $credDC
$dcVmConfig = Set-AzVMSourceImage -VM $dcVmConfig -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version 'latest'

# Add a network interface configuration for DC VM
$nicDC = New-AzNetworkInterface -Name "DCVMNIC" -ResourceGroupName 'rosalio-onboarding' -Location 'East US' -SubnetId $subnet.Id
$dcVmConfig = Add-AzVMNetworkInterface -VM $dcVmConfig -Id $nicDC.Id

# Create the Domain Controller VM
New-AzVM -ResourceGroupName 'rosalio-onboarding' -Location 'East US' -VM $dcVmConfig
