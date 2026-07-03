# Self-elevate
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

$username = "remoteuser"
$password = [System.Web.Security.Membership]::GeneratePassword(12, 2)
net user $username $password /add
net localgroup Administrators $username /add

$creds = "Username: $username`nPassword: $password"
Set-Content -Path "C:\Users\Public\ssh_creds.txt" -Value $creds

Write-Host "Done. Creds saved to C:\Users\Public\ssh_creds.txt"
Pause
