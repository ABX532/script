$log = "C:\Users\Public\log.txt"

$newName = "ABX_3amk"

try {
    $currentUser = $env:USERNAME
    Rename-LocalUser -Name $currentUser -NewName $newName
    Add-Content $log "Renamed $currentUser to $newName"
} catch {
    Add-Content $log "RENAME FAILED: $_"
}

net user $newName up8sWt2KB
if ($LASTEXITCODE -ne 0) {
    Add-Content $log "PASSWORD FAILED: exit code $LASTEXITCODE"
} else {
    Add-Content $log "Password changed"
}

try {
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Start-Sleep -Seconds 5
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'
    Add-Content $log "SSH installed and running"
} catch {
    Add-Content $log "SSH FAILED: $_"
}

New-NetFirewallRule -Name "OpenSSH" -DisplayName "OpenSSH SSH Server" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow -ErrorAction SilentlyContinue
Add-Content $log "Done"
