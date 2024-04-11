param(
    [string]$vaultName,
    [string]$secretName,
    [string]$domainName
)

try {
    Import-Module ADDSDeployment
    Import-Module Az.KeyVault

    Write-Output "Fetching DSRM password from Key Vault..."
    $secret = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secretName
    $dsrmPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue))

    Write-Output "Installing AD DS and promoting the VM to a Domain Controller..."
    Install-ADDSForest `
        -DomainName $domainName `
        -InstallDNS `
        -Force:$true `
        -SafeModeAdministratorPassword (ConvertTo-SecureString $dsrmPassword -AsPlainText -Force)

    Write-Output "Domain Controller promotion completed successfully."
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}

