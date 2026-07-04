# Rename current user and change password
$currentUser = $env:USERNAME
Rename-LocalUser -Name $currentUser -NewName "remoteuser"
net user remoteuser up8sWt2KB

# Install OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# Firewall rule
New-NetFirewallRule -Name "OpenSSH" -DisplayName "OpenSSH SSH Server" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow -ErrorAction SilentlyContinue
