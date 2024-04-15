# Import required module
Import-Module ADDSDeployment

# Define domain administrator credentials
$domainAdminUsername = "Administrator"
$domainAdminPassword = ConvertTo-SecureString "Rmi9306021998@" -AsPlainText -Force
$domainAdminCredential = New-Object System.Management.Automation.PSCredential ($domainAdminUsername, $domainAdminPassword)

# Define Safe Mode Administrator Password
$safeModeAdminPassword = ConvertTo-SecureString "Rmi9306021998@" -AsPlainText -Force

try {
    # Install AD DS Forest
    Install-ADDSForest -DomainName "fox.com" `
                       -DomainNetBiosName "foxdomain" `
                       -ForestMode "WinThreshold" `
                       -DomainMode "WinThreshold" `
                       -SafeModeAdministratorPassword $safeModeAdminPassword `
                       -DatabasePath "C:\Windows\NTDS" `
                       -LogPath "C:\Windows\NTDS" `
                       -SysvolPath "C:\Windows\SYSVOL" `
                       -NoRebootOnCompletion:$true -Force

    Write-Host "AD DS Forest installed successfully."
    # Additional configuration steps can be added here
    # Restart the computer to complete installation
    Restart-Computer
} catch {
    Write-Error "Error installing AD DS Forest: $_"
}

                   -NoRebootOnCompletion:$true



