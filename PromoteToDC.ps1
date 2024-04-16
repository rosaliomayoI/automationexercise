# PromoteToDC.ps1
# This script installs the Active Directory Domain Services role and promotes the server to a domain controller

# Configuration variables
$domainName = "foxlocal.com" # Change this to your desired domain name
$SafeModeAdministratorPassword = ConvertTo-SecureString "Rmi9306021998@" -AsPlainText -Force # Change the password
$credential = New-Object System.Management.Automation.PSCredential ("Administrator", $SafeModeAdministratorPassword)

# Install the AD DS role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Import ADDS Deployment module
Import-Module ADDSDeployment

# Install a new forest
Install-ADDSForest -DomainName $domainName -SafeModeAdministratorPassword $credential -Force -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -LogPath "C:\Windows\NTDS" -SysvolPath "C:\Windows\SYSVOL" -Confirm:$false

Write-Output "Active Directory Domain Controller promotion completed successfully."
