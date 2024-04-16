param(
    [string]$resourceGroupName = "rosalio-onboarding",
    [string]$location = "East US",
    [string]$adminUsername = "adminuser",
    [string]$adminPassword = "ComplexPassword!123"
)

# Ensuring the AzureRM and Az modules are available
if (-not(Get-Module -Name Az -ListAvailable)) {
    Install-Module -Name Az -Scope CurrentUser -AllowClobber -Force
}
Import-Module Az

# Connect to Azure account
Connect-AzAccount -UseDeviceAuthentication

# Create or verify resource group
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if (-not $resourceGroup) {
    $resourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $location
}

# Virtual Network and Subnet configuration
$vnetName = "vnet01"
$subnetName = "subnet01"
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.0.0.0/24"
$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix "10.0.0.0/16" -Subnet $subnetConfig

# Deploy Windows VM as Domain Controller
$dcVmName = "dc1"
$dcVmConfig = New-AzVMConfig -VMName $dcVmName -VMSize "Standard_DS1_v2"
$dcVm = Set-AzVMOperatingSystem -VM $dcVmConfig -Windows -ComputerName $dcVmName -Credential $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminUsername, $(ConvertTo-SecureString -String $adminPassword -AsPlainText -Force))
$dcVm = Set-AzVMSourceImage -VM $dcVm -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"
$dcVm = Add-AzVMNetworkInterface -VM $dcVm -Id $vnet.Subnets[0].Id
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $dcVm
$dcScriptUrl = "https://raw.githubusercontent.com/rosaliomayoI/automationexercise/main/PromoteToDC.ps1"
$dcScriptPath = "C:\Windows\Temp\promotetodc.ps1"
Invoke-WebRequest -Uri $dcScriptUrl -OutFile $dcScriptPath -UseBasicParsing
Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -VMName $dcVmName -CommandId 'RunPowerShellScript' -ScriptPath $dcScriptPath

# Deploy Linux VM for Django
$djangoVmName = "django1"
$djangoVmConfig = New-AzVMConfig -VMName $djangoVmName -VMSize "Standard_DS1_v2"
$djangoVm = Set-AzVMOperatingSystem -VM $djangoVmConfig -Linux -ComputerName $djangoVmName -Credential $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminUsername, $(ConvertTo-SecureString -String $adminPassword -AsPlainText -Force))
$djangoVm = Set-AzVMSourceImage -VM $djangoVm -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version "latest"
$djangoVm = Add-AzVMNetworkInterface -VM $djangoVm -Id $vnet.Subnets[0].Id
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $djangoVm
$djangoScriptUrl = "https://raw.githubusercontent.com/rosaliomayoI/automationexercise/main/installdjango.sh"
$djangoScriptPath = "/tmp/installdjango.sh"
Invoke-WebRequest -Uri $djangoScriptUrl -OutFile $djangoScriptPath -UseBasicParsing
Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -VMName $djangoVmName -CommandId 'RunShellScript' -ScriptPath $djangoScriptPath

# Output deployment details
Write-Output "Deployment completed successfully."
