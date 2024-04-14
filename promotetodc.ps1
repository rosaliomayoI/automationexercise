# Import required module
Import-Module ADDSDeployment

# Define domain administrator credentials
$domainAdminUsername = "Administrator"
$domainAdminPassword = ConvertTo-SecureString "YourPassword" -AsPlainText -Force
$domainAdminCredential = New-Object System.Management.Automation.PSCredential ($domainAdminUsername, $domainAdminPassword)

# Install AD DS Forest
Install-ADDSForest -DomainName "mydomain.com" `
                   -DomainNetBiosName "MYDOMAIN" `
                   -ForestMode "WinThreshold" `
                   -DomainMode "WinThreshold" `
                   -SafeModeAdministratorPassword $domainAdminCredential `
                   -DatabasePath "C:\Windows\NTDS" `
                   -LogPath "C:\Windows\NTDS" `
                   -SysvolPath "C:\Windows\SYSVOL" `
                   -NoRebootOnCompletion:$true


