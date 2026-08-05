$ErrorActionPreference = 'Stop'
$testEveryCompaction = $false

function Show-ProjectCleanupNotification {
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter(Mandatory = $true)][int]$Milestone,
        [Parameter(Mandatory = $true)][int]$Count,
        [Parameter(Mandatory = $true)][string]$SessionId
    )

    try {
        $popupScript = Join-Path $env:PLUGIN_ROOT 'hooks\show_checkpoint.ps1'
        if (-not (Test-Path -LiteralPath $popupScript)) {
            return
        }

        $encodedMessage = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Message))
        $encodedSessionId = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($SessionId))
        $arguments = "-NoProfile -Sta -ExecutionPolicy Bypass -File `"$popupScript`" -MessageBase64 $encodedMessage -Level $Milestone -Count $Count -SessionIdBase64 $encodedSessionId"
        Start-Process -FilePath 'powershell.exe' -ArgumentList $arguments -WindowStyle Hidden | Out-Null
    } catch {
        # systemMessage remains the in-app fallback.
    }
}

try {
    $inputJson = [Console]::In.ReadToEnd()
    $event = $inputJson | ConvertFrom-Json

    if ($event.trigger -ne 'auto' -or [string]::IsNullOrWhiteSpace($event.session_id)) {
        exit 0
    }

    $dataRoot = $env:PLUGIN_DATA
    if ([string]::IsNullOrWhiteSpace($dataRoot)) {
        exit 0
    }

    $stateDir = Join-Path $dataRoot 'compactions'
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null

    $safeSessionId = $event.session_id -replace '[^A-Za-z0-9._-]', '_'
    $statePath = Join-Path $stateDir ($safeSessionId + '.json')
    $count = 0
    $lastNotified = 0

    if (Test-Path -LiteralPath $statePath) {
        try {
            $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
            $count = [int]$state.count
            if ($null -ne $state.notified) {
                $lastNotified = [int]$state.notified
            }
        } catch {
            $count = 0
            $lastNotified = 0
        }
    }

    $count++
    $milestone = if ($count -ge 10) { 10 } elseif ($count -ge 5) { 5 } elseif ($count -ge 3) { 3 } else { 0 }
    $message = switch ($milestone) {
        3 { 'Light: 3 automatic compactions. Run /project-cleanup check?' }
        5 { 'Medium: 5 automatic compactions. Review the Performance Checkpoint.' }
        10 { "Heavy: $count automatic compactions. Run /project-cleanup now." }
        default { $null }
    }

    if ($testEveryCompaction) {
        $message = "TEST: automatic compaction #$count detected."
    }

    $shouldNotify = $testEveryCompaction -or ($message -and ($milestone -gt $lastNotified -or $milestone -eq 10))
    if ($shouldNotify -and -not $testEveryCompaction) {
        $lastNotified = $milestone
    }

    @{
        count = $count
        notified = $lastNotified
        cwd = [string]$event.cwd
        updated_at = [DateTime]::UtcNow.ToString('o')
    } | ConvertTo-Json | Set-Content -LiteralPath $statePath -Encoding UTF8

    if ($shouldNotify) {
        Show-ProjectCleanupNotification -Message $message -Milestone $milestone -Count $count -SessionId ([string]$event.session_id)
        @{ systemMessage = "ProjectCleanup checkpoint - $message Reply yes or no." } | ConvertTo-Json -Compress
    }
} catch {
    exit 0
}
