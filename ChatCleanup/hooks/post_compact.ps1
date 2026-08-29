$ErrorActionPreference = 'Stop'
$testEveryCompaction = $false

function Show-ChatCleanupCheckpoint {
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter(Mandatory = $true)][int]$Milestone,
        [Parameter(Mandatory = $true)][int]$Count,
        [string]$ChatName = '',
        [string]$ProjectName = ''
    )

    try {
        $popupScript = Join-Path $env:PLUGIN_ROOT 'hooks\show_checkpoint.ps1'
        if (-not (Test-Path -LiteralPath $popupScript)) { return }
        $encodedMessage = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Message))
        $encodedChatName = if ([string]::IsNullOrWhiteSpace($ChatName)) { '' } else { [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($ChatName)) }
        $encodedProjectName = if ([string]::IsNullOrWhiteSpace($ProjectName)) { '' } else { [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($ProjectName)) }
        $arguments = "-NoProfile -Sta -ExecutionPolicy Bypass -File `"$popupScript`" -MessageBase64 `"$encodedMessage`" -ChatNameBase64 `"$encodedChatName`" -ProjectNameBase64 `"$encodedProjectName`" -Level $Milestone -Count $Count"
        Start-Process -FilePath 'powershell.exe' -ArgumentList $arguments -WindowStyle Hidden | Out-Null
    } catch {
        # The chat message below remains the fallback when the desktop window fails.
    }
}

function Get-EventText {
    param(
        [Parameter(Mandatory = $true)][object]$Event,
        [Parameter(Mandatory = $true)][string[]]$Names
    )

    foreach ($name in $Names) {
        $property = $Event.PSObject.Properties[$name]
        if ($null -ne $property -and -not [string]::IsNullOrWhiteSpace([string]$property.Value)) {
            return [string]$property.Value
        }
    }
    foreach ($containerName in @('chat', 'thread', 'conversation')) {
        $container = $Event.PSObject.Properties[$containerName]
        if ($null -eq $container -or $null -eq $container.Value) { continue }
        foreach ($name in $Names) {
            $property = $container.Value.PSObject.Properties[$name]
            if ($null -ne $property -and -not [string]::IsNullOrWhiteSpace([string]$property.Value)) {
                return [string]$property.Value
            }
        }
    }
    return ''
}

function Get-CodexHome {
    param([Parameter(Mandatory = $true)][object]$Event)

    $configuredHome = [string]$env:CODEX_HOME
    if (-not [string]::IsNullOrWhiteSpace($configuredHome)) {
        $configuredIndex = Join-Path $configuredHome 'session_index.jsonl'
        if (Test-Path -LiteralPath $configuredIndex) { return $configuredHome }
    }

    foreach ($userRoot in @($env:USERPROFILE, $env:HOME)) {
        if ([string]::IsNullOrWhiteSpace([string]$userRoot)) { continue }
        $userHome = Join-Path $userRoot '.codex'
        if (Test-Path -LiteralPath (Join-Path $userHome 'session_index.jsonl')) { return $userHome }
    }

    $transcriptPath = [string]$Event.transcript_path
    if ([string]::IsNullOrWhiteSpace($transcriptPath)) { return '' }
    try {
        $directory = Split-Path -Path $transcriptPath -Parent
        for ($index = 0; $index -lt 4; $index++) {
            $directory = Split-Path -Path $directory -Parent
        }
        if (-not [string]::IsNullOrWhiteSpace($directory) -and (Test-Path -LiteralPath (Join-Path $directory 'session_index.jsonl'))) {
            return $directory
        }
    } catch { }
    return ''
}

function Get-IndexedChatName {
    param(
        [Parameter(Mandatory = $true)][object]$Event,
        [Parameter(Mandatory = $true)][string]$SessionId
    )

    $codexHome = Get-CodexHome -Event $Event
    if ([string]::IsNullOrWhiteSpace($codexHome)) { return '' }
    $indexPath = Join-Path $codexHome 'session_index.jsonl'
    try {
        foreach ($line in Get-Content -LiteralPath $indexPath -Encoding UTF8) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            try { $entry = $line | ConvertFrom-Json } catch { continue }
            if ([string]$entry.id -ne $SessionId) { continue }
            foreach ($name in @('thread_name', 'title', 'name')) {
                $property = $entry.PSObject.Properties[$name]
                if ($null -ne $property -and -not [string]::IsNullOrWhiteSpace([string]$property.Value)) {
                    return ([string]$property.Value).Trim()
                }
            }
            break
        }
    } catch { }
    return ''
}

function Get-ProjectName {
    param([Parameter(Mandatory = $true)][object]$Event)

    $cwd = [string]$Event.cwd
    if ([string]::IsNullOrWhiteSpace($cwd)) { return '' }
    try {
        $item = Get-Item -LiteralPath $cwd -Force
        if (-not [string]::IsNullOrWhiteSpace([string]$item.Name)) { return [string]$item.Name }
        return [string]$item.FullName
    } catch {
        try {
            $leaf = Split-Path -Path $cwd -Leaf
            if (-not [string]::IsNullOrWhiteSpace($leaf)) { return $leaf }
        } catch { }
    }
    return ''
}

function Test-IsSubagentEvent {
    param([Parameter(Mandatory = $true)][object]$Event)

    $subagentProperty = $Event.PSObject.Properties['subagent']
    if ($null -ne $subagentProperty -and $null -ne $subagentProperty.Value) { return $true }

    foreach ($name in @('is_subagent', 'isSubagent')) {
        $property = $Event.PSObject.Properties[$name]
        if ($null -ne $property -and [bool]$property.Value) { return $true }
    }

    foreach ($name in @('parent_session_id', 'parentSessionId', 'agent_path', 'agentPath')) {
        $property = $Event.PSObject.Properties[$name]
        if ($null -ne $property -and -not [string]::IsNullOrWhiteSpace([string]$property.Value)) { return $true }
    }

    foreach ($name in @('agent_id', 'agent_type')) {
        $property = $Event.PSObject.Properties[$name]
        if ($null -ne $property -and -not [string]::IsNullOrWhiteSpace([string]$property.Value)) { return $true }
    }

    $sourceProperty = $Event.PSObject.Properties['session_source']
    if ($null -ne $sourceProperty -and [string]$sourceProperty.Value -match '(?i)subagent') { return $true }
    return $false
}

function Get-SessionKey {
    param([Parameter(Mandatory = $true)][string]$SessionId)

    $bytes = [Text.Encoding]::UTF8.GetBytes($SessionId.ToLowerInvariant())
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $hash = $sha.ComputeHash($bytes) } finally { $sha.Dispose() }
    return ([BitConverter]::ToString($hash)).Replace('-', '').ToLowerInvariant()
}

try {
    $inputJson = [Console]::In.ReadToEnd()
    $event = $inputJson | ConvertFrom-Json
    if ($event.trigger -ne 'auto' -or [string]::IsNullOrWhiteSpace($event.session_id)) { exit 0 }
    if (Test-IsSubagentEvent -Event $event) { exit 0 }

    $sessionId = [string]$event.session_id
    $chatName = Get-EventText -Event $event -Names @('chat_name', 'chatName', 'chat_title', 'chatTitle', 'conversation_name', 'conversationName', 'conversation_title', 'conversationTitle', 'thread_name', 'threadName', 'thread_title', 'threadTitle', 'title', 'name')
    if ([string]::IsNullOrWhiteSpace($chatName)) {
        $chatName = Get-IndexedChatName -Event $event -SessionId $sessionId
    }
    if ([string]::IsNullOrWhiteSpace($chatName)) {
        $shortSessionId = $sessionId
        $chatName = 'Chat ' + $shortSessionId.Substring(0, [Math]::Min(8, $shortSessionId.Length))
    }
    $projectName = Get-ProjectName -Event $event

    $dataRoot = $env:PLUGIN_DATA
    if ([string]::IsNullOrWhiteSpace($dataRoot)) { exit 0 }

    $sessionKey = Get-SessionKey -SessionId $sessionId
    $stateDir = Join-Path $dataRoot 'compactions-v4'
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
    $statePath = Join-Path $stateDir ('session-' + $sessionKey + '.json')
    $count = 0
    $lastNotified = 0

    if (Test-Path -LiteralPath $statePath) {
        try {
            $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
            $count = [int]$state.count
            if ($null -ne $state.notified) { $lastNotified = [int]$state.notified }
        } catch {
            $count = 0
            $lastNotified = 0
        }
    }

    $count++
    $milestone = if ($count -ge 10) { 10 } elseif ($count -ge 5) { 5 } elseif ($count -ge 3) { 3 } else { 0 }
    $message = switch ($milestone) {
        3 { 'ChatCleanup: 3 compactacoes automaticas. Considere /chat-cleanup refresh.' }
        5 { 'ChatCleanup: 5 compactacoes automaticas. Rode /chat-cleanup refresh.' }
        10 { "ChatCleanup: $count compactacoes automaticas. Rode /chat-cleanup now." }
        default { $null }
    }
    if ($testEveryCompaction) { $message = "ChatCleanup TEST: automatic compaction #$count detected." }

    $shouldNotify = $testEveryCompaction -or ($message -and ($milestone -gt $lastNotified -or $milestone -eq 10))
    if ($shouldNotify -and -not $testEveryCompaction -and $milestone -gt $lastNotified) { $lastNotified = $milestone }

    @{
        count = $count
        notified = $lastNotified
        schema_version = 4
        main_session_id = $sessionId
        chat_name = $chatName
        project_name = $projectName
        updated_at = [DateTime]::UtcNow.ToString('o')
    } | ConvertTo-Json | Set-Content -LiteralPath $statePath -Encoding UTF8

    if ($shouldNotify) {
        Show-ChatCleanupCheckpoint -Message $message -Milestone $milestone -Count $count -ChatName $chatName -ProjectName $projectName
        @{ systemMessage = "$message A janela copia os comandos; cole e envie no chat." } | ConvertTo-Json -Compress
    }
} catch {
    exit 0
}
