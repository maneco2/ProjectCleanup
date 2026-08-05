param(
    [Parameter(Mandatory = $true)][string]$MessageBase64,
    [Parameter(Mandatory = $true)][int]$Level,
    [Parameter(Mandatory = $true)][int]$Count,
    [string]$SessionIdBase64 = ''
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class ProjectCleanupConsole {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
'@

$message = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($MessageBase64))
$sessionId = if ([string]::IsNullOrWhiteSpace($SessionIdBase64)) {
    ''
} else {
    [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($SessionIdBase64))
}

$levelName = switch ($Level) {
    3 { 'LIGHT' }
    5 { 'MEDIUM' }
    10 { 'HEAVY' }
    default { 'CHECKPOINT' }
}

$accent = switch ($Level) {
    3 { [System.Drawing.Color]::FromArgb(34, 139, 94) }
    5 { [System.Drawing.Color]::FromArgb(209, 154, 22) }
    10 { [System.Drawing.Color]::FromArgb(196, 48, 43) }
    default { [System.Drawing.Color]::FromArgb(55, 100, 180) }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'ProjectCleanup'
$form.ClientSize = New-Object System.Drawing.Size(920, 570)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.TopMost = $true
$form.BackColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)

$header = New-Object System.Windows.Forms.Panel
$header.Dock = 'Top'
$header.Height = 92
$header.BackColor = $accent
$form.Controls.Add($header)

$title = New-Object System.Windows.Forms.Label
$title.Text = 'Performance Checkpoint'
$title.ForeColor = [System.Drawing.Color]::White
$title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 16)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(26, 20)
$header.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = 'This chat has been compacted several times and may need a clean handoff.'
$subtitle.ForeColor = [System.Drawing.Color]::White
$subtitle.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$subtitle.AutoSize = $true
$subtitle.Location = New-Object System.Drawing.Point(28, 57)
$header.Controls.Add($subtitle)

$badge = New-Object System.Windows.Forms.Label
$badge.Text = $levelName
$badge.TextAlign = 'MiddleCenter'
$badge.ForeColor = [System.Drawing.Color]::White
$badge.BackColor = $accent
$badge.BorderStyle = 'FixedSingle'
$badge.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$badge.Size = New-Object System.Drawing.Size(92, 36)
$badge.Location = New-Object System.Drawing.Point(500, 28)
$header.Controls.Add($badge)

$summary = New-Object System.Windows.Forms.Panel
$summary.Dock = 'Left'
$summary.Width = 300
$summary.BackColor = [System.Drawing.Color]::FromArgb(238, 241, 244)
$form.Controls.Add($summary)

$summaryTitle = New-Object System.Windows.Forms.Label
$summaryTitle.Text = 'AUTOMATIC COMPACTIONS'
$summaryTitle.ForeColor = [System.Drawing.Color]::FromArgb(105, 114, 124)
$summaryTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 8)
$summaryTitle.AutoSize = $true
$summaryTitle.Location = New-Object System.Drawing.Point(25, 27)
$summary.Controls.Add($summaryTitle)

$countLabel = New-Object System.Windows.Forms.Label
$countLabel.Text = [string]$Count
$countLabel.ForeColor = [System.Drawing.Color]::FromArgb(43, 49, 56)
$countLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 30)
$countLabel.AutoSize = $true
$countLabel.Location = New-Object System.Drawing.Point(24, 53)
$summary.Controls.Add($countLabel)

$detected = New-Object System.Windows.Forms.Label
$detected.Text = 'detected'
$detected.ForeColor = [System.Drawing.Color]::FromArgb(109, 117, 128)
$detected.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$detected.AutoSize = $true
$detected.Location = New-Object System.Drawing.Point(($countLabel.Right + 10), 79)
$summary.Controls.Add($detected)

$summaryCopy = New-Object System.Windows.Forms.Label
$summaryCopy.Text = 'Choose how to continue. ProjectCleanup copies the selected command so you can paste and send it in the correct Codex chat.'
$summaryCopy.ForeColor = [System.Drawing.Color]::FromArgb(81, 91, 101)
$summaryCopy.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$summaryCopy.Size = New-Object System.Drawing.Size(246, 76)
$summaryCopy.Location = New-Object System.Drawing.Point(25, 124)
$summary.Controls.Add($summaryCopy)

function Add-LevelMarker {
    param([int]$Y, [string]$Text, [bool]$Active)

    $marker = New-Object System.Windows.Forms.Label
    $marker.Text = if ($Active) { [char]0x25CF } else { [char]0x25CB }
    $marker.ForeColor = if ($Active) { $accent } else { [System.Drawing.Color]::FromArgb(165, 173, 182) }
    $marker.Font = New-Object System.Drawing.Font('Segoe UI Symbol', 13)
    $marker.AutoSize = $true
    $marker.Location = New-Object System.Drawing.Point(25, $Y)
    $summary.Controls.Add($marker)

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.ForeColor = if ($Active) { [System.Drawing.Color]::FromArgb(32, 38, 45) } else { [System.Drawing.Color]::FromArgb(112, 121, 132) }
    $fontStyle = if ($Active) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $label.Font = New-Object System.Drawing.Font('Segoe UI', 9, $fontStyle)
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(53, ($Y + 4))
    $summary.Controls.Add($label)
}

Add-LevelMarker -Y 226 -Text '3 compactions - Light' -Active ($Level -eq 3)
Add-LevelMarker -Y 270 -Text '5 compactions - Medium' -Active ($Level -eq 5)
Add-LevelMarker -Y 314 -Text '10 compactions - Heavy' -Active ($Level -eq 10)

$detail = New-Object System.Windows.Forms.Label
$detail.Text = $message
$detail.ForeColor = [System.Drawing.Color]::FromArgb(83, 92, 102)
$detail.Font = New-Object System.Drawing.Font('Segoe UI', 8.5)
$detail.Size = New-Object System.Drawing.Size(246, 54)
$detail.Location = New-Object System.Drawing.Point(25, 385)
$summary.Controls.Add($detail)

$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Dock = 'Fill'
$tabs.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.Controls.Add($tabs)
$tabs.BringToFront()

$actions = New-Object System.Windows.Forms.TabPage
$actions.Text = 'Recommended Actions'
$actions.BackColor = [System.Drawing.Color]::White
$tabs.TabPages.Add($actions)

$commandsPage = New-Object System.Windows.Forms.TabPage
$commandsPage.Text = 'All Commands'
$commandsPage.BackColor = [System.Drawing.Color]::White
$tabs.TabPages.Add($commandsPage)

$actionsTitle = New-Object System.Windows.Forms.Label
$actionsTitle.Text = 'Choose the next action'
$actionsTitle.ForeColor = [System.Drawing.Color]::FromArgb(32, 38, 45)
$actionsTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 13)
$actionsTitle.AutoSize = $true
$actionsTitle.Location = New-Object System.Drawing.Point(24, 24)
$actions.Controls.Add($actionsTitle)

$actionsHint = New-Object System.Windows.Forms.Label
$actionsHint.Text = 'The command is copied to the clipboard. Paste and send it in Codex.'
$actionsHint.ForeColor = [System.Drawing.Color]::FromArgb(105, 114, 124)
$actionsHint.Font = New-Object System.Drawing.Font('Segoe UI', 8.5)
$actionsHint.AutoSize = $true
$actionsHint.Location = New-Object System.Drawing.Point(25, 52)
$actions.Controls.Add($actionsHint)

$status = New-Object System.Windows.Forms.Label
$status.Text = 'No command copied yet.'
$status.ForeColor = [System.Drawing.Color]::FromArgb(89, 112, 99)
$status.Font = New-Object System.Drawing.Font('Segoe UI', 8.5)
$status.AutoSize = $true
$status.Location = New-Object System.Drawing.Point(25, 408)
$actions.Controls.Add($status)

function Add-ActionRow {
    param(
        [int]$Index,
        [int]$Y,
        [string]$Title,
        [string]$Description,
        [string]$ButtonText,
        [string]$Command,
        [bool]$Primary = $false
    )

    $line = New-Object System.Windows.Forms.Panel
    $line.BackColor = [System.Drawing.Color]::FromArgb(221, 225, 229)
    $line.Size = New-Object System.Drawing.Size(568, 1)
    $line.Location = New-Object System.Drawing.Point(24, $Y)
    $actions.Controls.Add($line)

    $number = New-Object System.Windows.Forms.Label
    $number.Text = ('{0:D2}' -f $Index)
    $number.TextAlign = 'MiddleCenter'
    $number.BackColor = [System.Drawing.Color]::FromArgb(238, 241, 244)
    $number.ForeColor = [System.Drawing.Color]::FromArgb(91, 103, 115)
    $number.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 8)
    $number.Size = New-Object System.Drawing.Size(32, 32)
    $number.Location = New-Object System.Drawing.Point(25, ($Y + 22))
    $actions.Controls.Add($number)

    $rowTitle = New-Object System.Windows.Forms.Label
    $rowTitle.Text = $Title
    $rowTitle.ForeColor = [System.Drawing.Color]::FromArgb(32, 38, 45)
    $rowTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
    $rowTitle.AutoSize = $true
    $rowTitle.Location = New-Object System.Drawing.Point(80, ($Y + 18))
    $actions.Controls.Add($rowTitle)

    $rowDescription = New-Object System.Windows.Forms.Label
    $rowDescription.Text = $Description
    $rowDescription.ForeColor = [System.Drawing.Color]::FromArgb(112, 121, 132)
    $rowDescription.Font = New-Object System.Drawing.Font('Segoe UI', 8)
    $rowDescription.Size = New-Object System.Drawing.Size(300, 34)
    $rowDescription.Location = New-Object System.Drawing.Point(80, ($Y + 42))
    $actions.Controls.Add($rowDescription)

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $ButtonText
    $button.Size = New-Object System.Drawing.Size(134, 38)
    $button.Location = New-Object System.Drawing.Point(458, ($Y + 22))
    $button.FlatStyle = 'Flat'
    $button.FlatAppearance.BorderSize = 1
    if ($Primary) {
        $button.BackColor = $accent
        $button.ForeColor = [System.Drawing.Color]::White
        $button.FlatAppearance.BorderColor = $accent
    } else {
        $button.BackColor = [System.Drawing.Color]::White
        $button.ForeColor = [System.Drawing.Color]::FromArgb(48, 54, 61)
        $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(184, 190, 197)
    }

    $commandToCopy = $Command
    $statusToUpdate = $status
    $buttonToUpdate = $button
    $button.Add_Click({
        [System.Windows.Forms.Clipboard]::SetText($commandToCopy)
        $statusToUpdate.Text = "$commandToCopy copied. Paste and send it in Codex."
        $buttonToUpdate.Text = 'Copied'
    }.GetNewClosure())
    $actions.Controls.Add($button)
}

Add-ActionRow -Index 1 -Y 83 -Title 'Check chat health' -Description 'Diagnose context weight without changing files or chats.' -ButtonText 'Copy Check' -Command '/project-cleanup check'
Add-ActionRow -Index 2 -Y 166 -Title 'Refresh handoff' -Description 'Update agent.md and remain in the current chat.' -ButtonText 'Copy Refresh' -Command '/project-cleanup refresh'
Add-ActionRow -Index 3 -Y 249 -Title 'Start clean handoff' -Description 'Prepare agent.md and begin the guided new-chat flow.' -ButtonText 'Copy Now' -Command '/project-cleanup now' -Primary $true

$footerLine = New-Object System.Windows.Forms.Panel
$footerLine.BackColor = [System.Drawing.Color]::FromArgb(221, 225, 229)
$footerLine.Size = New-Object System.Drawing.Size(568, 1)
$footerLine.Location = New-Object System.Drawing.Point(24, 386)
$actions.Controls.Add($footerLine)

$continueButton = New-Object System.Windows.Forms.Button
$continueButton.Text = 'Continue'
$continueButton.Size = New-Object System.Drawing.Size(118, 38)
$continueButton.Location = New-Object System.Drawing.Point(474, 396)
$continueButton.FlatStyle = 'Flat'
$continueButton.BackColor = [System.Drawing.Color]::White
$continueButton.ForeColor = [System.Drawing.Color]::FromArgb(48, 54, 61)
$continueButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(184, 190, 197)
$formToClose = $form
$continueButton.Add_Click({ $formToClose.Close() }.GetNewClosure())
$actions.Controls.Add($continueButton)

if (-not [string]::IsNullOrWhiteSpace($sessionId)) {
    $openChatButton = New-Object System.Windows.Forms.Button
    $openChatButton.Text = 'Open Current Chat'
    $openChatButton.Size = New-Object System.Drawing.Size(150, 38)
    $openChatButton.Location = New-Object System.Drawing.Point(310, 396)
    $openChatButton.FlatStyle = 'Flat'
    $openChatButton.BackColor = [System.Drawing.Color]::White
    $openChatButton.ForeColor = [System.Drawing.Color]::FromArgb(48, 54, 61)
    $openChatButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(184, 190, 197)
    $threadLink = "codex://threads/$sessionId"
    $openChatButton.Add_Click({ Start-Process $threadLink }.GetNewClosure())
    $actions.Controls.Add($openChatButton)
}

$commandsTitle = New-Object System.Windows.Forms.Label
$commandsTitle.Text = 'ProjectCleanup commands'
$commandsTitle.ForeColor = [System.Drawing.Color]::FromArgb(32, 38, 45)
$commandsTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 13)
$commandsTitle.AutoSize = $true
$commandsTitle.Location = New-Object System.Drawing.Point(24, 22)
$commandsPage.Controls.Add($commandsTitle)

$commandsHint = New-Object System.Windows.Forms.Label
$commandsHint.Text = 'Copy a command, return to the correct Codex chat, paste it, and send.'
$commandsHint.ForeColor = [System.Drawing.Color]::FromArgb(105, 114, 124)
$commandsHint.Font = New-Object System.Drawing.Font('Segoe UI', 8.5)
$commandsHint.AutoSize = $true
$commandsHint.Location = New-Object System.Drawing.Point(25, 50)
$commandsPage.Controls.Add($commandsHint)

$commandsStatus = New-Object System.Windows.Forms.Label
$commandsStatus.Text = 'Buttons copy commands only; they do not submit messages automatically.'
$commandsStatus.ForeColor = [System.Drawing.Color]::FromArgb(89, 112, 99)
$commandsStatus.Font = New-Object System.Drawing.Font('Segoe UI', 8.5)
$commandsStatus.AutoSize = $true
$commandsStatus.Location = New-Object System.Drawing.Point(25, 407)
$commandsPage.Controls.Add($commandsStatus)

function Add-CommandRow {
    param(
        [int]$Y,
        [string]$Command,
        [string]$Description
    )

    $commandLabel = New-Object System.Windows.Forms.Label
    $commandLabel.Text = $Command
    $commandLabel.ForeColor = [System.Drawing.Color]::FromArgb(32, 38, 45)
    $commandLabel.Font = New-Object System.Drawing.Font('Consolas', 9)
    $commandLabel.AutoSize = $true
    $commandLabel.Location = New-Object System.Drawing.Point(25, $Y)
    $commandsPage.Controls.Add($commandLabel)

    $descriptionLabel = New-Object System.Windows.Forms.Label
    $descriptionLabel.Text = $Description
    $descriptionLabel.ForeColor = [System.Drawing.Color]::FromArgb(112, 121, 132)
    $descriptionLabel.Font = New-Object System.Drawing.Font('Segoe UI', 8)
    $descriptionLabel.Size = New-Object System.Drawing.Size(300, 30)
    $descriptionLabel.Location = New-Object System.Drawing.Point(25, ($Y + 20))
    $commandsPage.Controls.Add($descriptionLabel)

    $copyButton = New-Object System.Windows.Forms.Button
    $copyButton.Text = 'Copy'
    $copyButton.Size = New-Object System.Drawing.Size(92, 32)
    $copyButton.Location = New-Object System.Drawing.Point(500, ($Y + 3))
    $copyButton.FlatStyle = 'Flat'
    $copyButton.BackColor = [System.Drawing.Color]::White
    $copyButton.ForeColor = [System.Drawing.Color]::FromArgb(48, 54, 61)
    $copyButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(184, 190, 197)
    $commandToCopy = $Command
    $statusToUpdate = $commandsStatus
    $buttonToUpdate = $copyButton
    $copyButton.Add_Click({
        [System.Windows.Forms.Clipboard]::SetText($commandToCopy)
        $statusToUpdate.Text = "$commandToCopy copied. Paste and send it in Codex."
        $buttonToUpdate.Text = 'Copied'
    }.GetNewClosure())
    $commandsPage.Controls.Add($copyButton)
}

Add-CommandRow -Y 82 -Command '/project-cleanup' -Description 'Start the guided cleanup flow.'
Add-CommandRow -Y 134 -Command '/project-cleanup check' -Description 'Diagnose chat weight without changing files or chats.'
Add-CommandRow -Y 186 -Command '/project-cleanup preview' -Description 'Draft the proposed agent.md in chat only.'
Add-CommandRow -Y 238 -Command '/project-cleanup status' -Description 'Report whether agent.md exists and looks fresh or stale.'
Add-CommandRow -Y 290 -Command '/project-cleanup refresh' -Description 'Refresh agent.md without creating a new chat.'
Add-CommandRow -Y 342 -Command '/project-cleanup now' -Description 'Run the complete validated handoff flow.'

$form.AcceptButton = $continueButton
$form.CancelButton = $continueButton

# Create the form handle first, then hide only the PowerShell console window.
[void]$form.Handle
$consoleWindow = [ProjectCleanupConsole]::GetConsoleWindow()
if ($consoleWindow -ne [IntPtr]::Zero) {
    [void][ProjectCleanupConsole]::ShowWindow($consoleWindow, 0)
}
$formToShow = $form
$form.Add_Shown({
    [void][ProjectCleanupConsole]::ShowWindow($formToShow.Handle, 5)
    [void][ProjectCleanupConsole]::SetForegroundWindow($formToShow.Handle)
}.GetNewClosure())

[void]$form.ShowDialog()
