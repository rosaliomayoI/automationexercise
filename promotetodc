param(
    [string]$vaultName,
    [string]$secretName,
    [string]$domainName
)

Import-Module ADDSDeployment
Import-Module Az.KeyVault

# Fetch the DSRM password from the Key Vault
$secret = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secretName
$dsrmPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue))

# Install AD DS and promote the VM to a Domain Controller
Install-ADDSForest `
    -DomainName $domainName `
    -InstallDNS `
    -Force:$true `
    -SafeModeAdministratorPassword (ConvertTo-SecureString $dsrmPassword -AsPlainText -Force)
