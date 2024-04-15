# Import required module
Import-Module ADDSDeployment

# Define domain administrator credentials
$domainAdminUsername = "fox"
$domainAdminPassword = ConvertTo-SecureString "Rmi9306021998@" -AsPlainText -Force
$domainAdminCredential = New-Object System.Management.Automation.PSCredential ($domainAdminUsername, $domainAdminPassword)

# Define Safe Mode Administrator Password
$safeModeAdminPassword = ConvertTo-SecureString "Rmi9306021998@" -AsPlainText -Force

# Install AD DS Forest
Install-ADDSForest -DomainName "fox.com" `
                   -DomainNetBiosName "foxdomain" `
                   -ForestMode "WinThreshold" `
                   -DomainMode "WinThreshold" `
                   -SafeModeAdministratorPassword $safeModeAdminPassword `
                   -DatabasePath "C:\Windows\NTDS" `
                   -LogPath "C:\Windows\NTDS" `
                   -SysvolPath "C:\Windows\SYSVOL" `
                   -NoRebootOnCompletion:$true



