$log = "C:\Users\Public\log.txt"

try {
    $currentUser = $env:USERNAME
    Rename-LocalUser -Name $currentUser -NewName "remoteuser"
    Add-Content $log "Renamed $currentUser to remoteuser"
} catch {
    Add-Content $log "RENAME FAILED: $_"
}

try {
    net user remoteuser up8sWt2KB
    Add-Content $log "Password changed"
} catch {
    Add-Content $log "PASSWORD FAILED: $_"
}

try {
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'
    Add-Content $log "SSH installed and running"
} catch {
    Add-Content $log "SSH FAILED: $_"
}

New-NetFirewallRule -Name "OpenSSH" -DisplayName "OpenSSH SSH Server" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow -ErrorAction SilentlyContinue
Add-Content $log "Done"
