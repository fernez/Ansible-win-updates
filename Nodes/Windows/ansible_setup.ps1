#Ansible deployment script for Windows machine by PK
#Installation of Windows features
Install-WindowsFeature telnet-client
Install-WindowsFeature Simple-TCPIP
 
 #Set-up Ansible environment using official Ansible script
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"
 
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
 
powershell.exe -ExecutionPolicy ByPass -File $file
winrm enumerate winrm/config/Listener
 
#Definition of new user for Ansible
$Username = "ansadmin"
$Password = "*******"
 
$group = "Administrators"
 
$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$existing = $adsi.Children | where {$_.SchemaClassName -eq 'user' -and $_.Name -eq $Username }
 
if ($existing -eq $null) {
 
    Write-Host "Creating new local user $Username."
    & NET USER $Username $Password /add /y /expires:never
    
    Write-Host "Adding local user $Username to $group."
    & NET LOCALGROUP $group $Username /add
 
}
else {
    Write-Host "Setting password for existing local user $Username."
    $existing.SetPassword($Password)
}
 
Write-Host "Ensuring password for $Username never expires."
& WMIC USERACCOUNT WHERE "Name='$Username'" SET PasswordExpires=FALSE
 
