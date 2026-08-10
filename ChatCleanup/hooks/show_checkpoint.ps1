param(
    [string]$MessageBase64 = '',
    [ValidateSet(3, 5, 10)][int]$Level = 3,
    [int]$Count = 0,
    [switch]$Guided
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class ChatCleanupConsole {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern IntPtr SendMessage(IntPtr hWnd, int message, IntPtr wParam, IntPtr lParam);

    [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
    public static extern int SetCurrentProcessExplicitAppUserModelID(string appId);

    [DllImport("dwmapi.dll")]
    public static extern int DwmSetWindowAttribute(IntPtr hWnd, int attribute, ref int value, int valueSize);

    public static void UseDarkTitleBar(IntPtr hWnd) {
        int enabled = 1;
        const int DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
        if (DwmSetWindowAttribute(hWnd, DWMWA_USE_IMMERSIVE_DARK_MODE, ref enabled, sizeof(int)) != 0) {
            DwmSetWindowAttribute(hWnd, 19, ref enabled, sizeof(int));
        }
    }

    [DllImport("user32.dll")]
    public static extern int GetWindowLong(IntPtr hWnd, int index);

    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hWnd, int index, int value);

    public static void HideFromTaskbar(IntPtr hWnd) {
        const int GWL_EXSTYLE = -20;
        const int WS_EX_TOOLWINDOW = 0x00000080;
        const int WS_EX_APPWINDOW = 0x00040000;
        int style = GetWindowLong(hWnd, GWL_EXSTYLE);
        SetWindowLong(hWnd, GWL_EXSTYLE, (style | WS_EX_TOOLWINDOW) & ~WS_EX_APPWINDOW);
    }

    public static void SetWindowIcon(IntPtr hWnd, IntPtr icon) {
        const int WM_SETICON = 0x0080;
        const int ICON_SMALL = 0;
        const int ICON_BIG = 1;
        SendMessage(hWnd, WM_SETICON, new IntPtr(ICON_SMALL), icon);
        SendMessage(hWnd, WM_SETICON, new IntPtr(ICON_BIG), icon);
    }
}
'@

function Get-Text {
    param([Parameter(Mandatory = $true)][string]$Key)
    $value = $strings.PSObject.Properties[$Key]
    if ($null -eq $value) { return $Key }
    [string]$value.Value
}

function Get-FormattedText {
    param(
        [Parameter(Mandatory = $true)][string]$Key,
        [Parameter(Mandatory = $true)][object]$Value
    )
    (Get-Text -Key $Key) -f $Value
}

function Add-TextLabel {
    param(
        [Parameter(Mandatory = $true)][System.Windows.Forms.Control]$Parent,
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][System.Drawing.Point]$Location,
        [Parameter(Mandatory = $true)][System.Drawing.Size]$Size,
        [System.Drawing.Font]$Font,
        [System.Drawing.Color]$Color = ([System.Drawing.Color]::FromArgb(232, 237, 242))
    )
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.ForeColor = $Color
    $label.Font = if ($null -eq $Font) { New-Object System.Drawing.Font('Segoe UI', 9) } else { $Font }
    $label.Location = $Location
    $label.Size = $Size
    $label.AutoEllipsis = $true
    $Parent.Controls.Add($label)
    $label
}

function New-ChatCleanupIcon {
    $bitmap = New-Object System.Drawing.Bitmap(32, 32)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $background = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(18, 18, 22))
    $whitePen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 2.2)
    $whitePen.StartCap = 'Round'
    $whitePen.EndCap = 'Round'
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc(1, 1, 9, 9, 180, 90)
    $path.AddArc(22, 1, 9, 9, 270, 90)
    $path.AddArc(22, 22, 9, 9, 0, 90)
    $path.AddArc(1, 22, 9, 9, 90, 90)
    $path.CloseFigure()
    $graphics.FillPath($background, $path)

    # Codex/OpenAI-style six-loop mark, kept native so the plugin has no image dependency.
    for ($angle = 0; $angle -lt 360; $angle += 60) {
        $graphics.ResetTransform()
        $graphics.TranslateTransform(16, 16)
        $graphics.RotateTransform($angle)
        $graphics.DrawEllipse($whitePen, -4.5, -12, 9, 14)
    }
    $graphics.ResetTransform()
    $graphics.FillEllipse($background, 12.2, 12.2, 7.6, 7.6)
    $graphics.DrawEllipse($whitePen, 12.2, 12.2, 7.6, 7.6)
    $graphics.Dispose()
    $path.Dispose()
    $background.Dispose()
    $whitePen.Dispose()
    $icon = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
    [pscustomobject]@{ Bitmap = $bitmap; Icon = $icon }
}

$catalogPath = Join-Path $PSScriptRoot 'checkpoint-locales.json'
$catalog = if (Test-Path -LiteralPath $catalogPath) {
    Get-Content -LiteralPath $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
} else {
    [pscustomobject]@{ en = [pscustomobject]@{ formTitle = 'ChatCleanup'; title = 'Performance Checkpoint'; subtitle = 'This chat may need a clean handoff.'; automatic = 'AUTOMATIC COMPACTIONS'; detected = 'detected'; summary = 'Copy a command and paste it into Codex.'; recommended = 'Recommended Actions'; allCommands = 'All Commands'; copy = 'Copy'; choose = 'Choose the next action'; hint = 'Copy the command, then paste and send it in Codex.'; guidedTitle = 'Open guided flow'; guidedDescription = 'Show ChatCleanup commands.'; checkTitle = 'Check chat health'; checkDescription = 'Diagnose context pressure without changing files.'; refreshTitle = 'Refresh AGENTS.md'; refreshDescription = 'Update the current project handoff.'; nowTitle = 'Start clean handoff'; nowDescription = 'Refresh the handoff and start a clean chat.'; copyGuided = 'Copy Guided'; copyCheck = 'Copy Check'; copyRefresh = 'Copy Refresh'; copyNow = 'Copy Now'; copied = '{0} copied.'; none = 'No command copied yet.'; continue = 'Continue'; commandsTitle = 'ChatCleanup commands'; commandsHint = 'Copy, paste and send in Codex.'; commandsStatus = 'Buttons copy commands only.'; guidedCommand = 'Open the guided command chooser.'; checkCommand = 'Check the current chat health.'; previewCommand = 'Preview the handoff in chat only.'; statusCommand = 'Check AGENTS.md presence and freshness.'; refreshCommand = 'Refresh the active project handoff.'; nowCommand = 'Run the complete handoff flow.'; light = 'LIGHT'; medium = 'MEDIUM'; heavy = 'HEAVY' } }
}

$culture = [Globalization.CultureInfo]::CurrentUICulture.Name
$locale = $catalog.PSObject.Properties[$culture]
if ($null -eq $locale) {
    $baseCulture = $culture -split '-'
    $baseKey = $baseCulture[0]
    $catalogKey = if ($baseKey -eq 'pt') { 'pt-BR' } elseif ($baseKey -eq 'zh') { 'zh-Hans' } else { $baseKey }
    $locale = $catalog.PSObject.Properties[$catalogKey]
}
if ($null -eq $locale) { $locale = $catalog.PSObject.Properties['en'] }
$strings = $locale.Value
$copyLabel = Get-Text -Key 'copy'

$message = if ([string]::IsNullOrWhiteSpace($MessageBase64)) {
    Get-Text -Key 'summary'
} else {
    try { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($MessageBase64)) } catch { Get-Text -Key 'summary' }
}

$levelName = switch ($Level) {
    3 { Get-Text -Key 'light' }
    5 { Get-Text -Key 'medium' }
    10 { Get-Text -Key 'heavy' }
    default { Get-Text -Key 'light' }
}

$accent = switch ($Level) {
    3 { [System.Drawing.Color]::FromArgb(24, 121, 82) }
    5 { [System.Drawing.Color]::FromArgb(160, 111, 0) }
    10 { [System.Drawing.Color]::FromArgb(146, 39, 35) }
    default { [System.Drawing.Color]::FromArgb(40, 82, 145) }
}
$surface = [System.Drawing.Color]::FromArgb(18, 22, 28)
$surfaceRaised = [System.Drawing.Color]::FromArgb(25, 31, 39)
$surfaceSoft = [System.Drawing.Color]::FromArgb(31, 39, 49)
$border = [System.Drawing.Color]::FromArgb(62, 73, 86)
$textPrimary = [System.Drawing.Color]::FromArgb(232, 237, 242)
$textSecondary = [System.Drawing.Color]::FromArgb(171, 184, 198)
$textMuted = [System.Drawing.Color]::FromArgb(132, 146, 162)

$form = New-Object System.Windows.Forms.Form
$form.Text = Get-Text -Key 'formTitle'
$form.ClientSize = New-Object System.Drawing.Size(920, 570)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.TopMost = $true
$form.BackColor = $surface
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.RightToLeft = if ($culture -like 'ar*') { 'Yes' } else { 'No' }
$null = [ChatCleanupConsole]::SetCurrentProcessExplicitAppUserModelID('ChatCleanup.Codex')
$iconState = New-ChatCleanupIcon
$form.Icon = $iconState.Icon

$header = New-Object System.Windows.Forms.Panel
$header.Dock = 'None'
$header.Location = New-Object System.Drawing.Point(0, 0)
$header.Size = New-Object System.Drawing.Size(920, 92)
$header.Height = 92
$header.BackColor = $accent
$form.Controls.Add($header)
$headerLogo = New-Object System.Windows.Forms.PictureBox
$headerLogo.Image = $iconState.Bitmap
$headerLogo.SizeMode = 'Zoom'
$headerLogo.Location = New-Object System.Drawing.Point(22, 18)
$headerLogo.Size = New-Object System.Drawing.Size(30, 30)
$header.Controls.Add($headerLogo)
Add-TextLabel -Parent $header -Text (Get-Text -Key 'title') -Location (New-Object System.Drawing.Point(64, 14)) -Size (New-Object System.Drawing.Size(390, 34)) -Font (New-Object System.Drawing.Font('Segoe UI Semibold', 16)) -Color ([System.Drawing.Color]::White) | Out-Null
Add-TextLabel -Parent $header -Text (Get-Text -Key 'subtitle') -Location (New-Object System.Drawing.Point(66, 55)) -Size (New-Object System.Drawing.Size(390, 24)) -Font (New-Object System.Drawing.Font('Segoe UI', 9)) -Color ([System.Drawing.Color]::White) | Out-Null
$badge = Add-TextLabel -Parent $header -Text $levelName -Location (New-Object System.Drawing.Point(420, 28)) -Size (New-Object System.Drawing.Size(126, 36)) -Font (New-Object System.Drawing.Font('Segoe UI Semibold', 9)) -Color ([System.Drawing.Color]::White)
$badge.TextAlign = 'MiddleCenter'
$badge.BorderStyle = 'FixedSingle'
$badge.AutoEllipsis = $false
$positionBadge = {
    $badgeX = [Math]::Max(430, $header.ClientSize.Width - $badge.Width - 18)
    $badge.Location = New-Object System.Drawing.Point($badgeX, 28)
}.GetNewClosure()
$header.Add_SizeChanged({ & $positionBadge }.GetNewClosure())

$body = New-Object System.Windows.Forms.Panel
$body.Dock = 'None'
$body.Location = New-Object System.Drawing.Point(0, 92)
$body.Size = New-Object System.Drawing.Size(920, 478)
$body.BackColor = $surface

$summaryPanel = New-Object System.Windows.Forms.Panel
$summaryPanel.Dock = 'None'
$summaryPanel.Location = New-Object System.Drawing.Point(0, 0)
$summaryPanel.Size = New-Object System.Drawing.Size(300, 478)
$summaryPanel.Width = 300
$summaryPanel.BackColor = $surfaceRaised
$summaryPanel.Padding = New-Object System.Windows.Forms.Padding(0)
Add-TextLabel -Parent $summaryPanel -Text (Get-Text -Key 'automatic') -Location (New-Object System.Drawing.Point(25, 27)) -Size (New-Object System.Drawing.Size(246, 22)) -Font (New-Object System.Drawing.Font('Segoe UI Semibold', 8)) -Color $textMuted | Out-Null
$countLabel = Add-TextLabel -Parent $summaryPanel -Text ([string]$Count) -Location (New-Object System.Drawing.Point(24, 53)) -Size (New-Object System.Drawing.Size(60, 48)) -Font (New-Object System.Drawing.Font('Segoe UI Semibold', 30))
Add-TextLabel -Parent $summaryPanel -Text (Get-Text -Key 'detected') -Location (New-Object System.Drawing.Point(88, 79)) -Size (New-Object System.Drawing.Size(150, 22)) -Font (New-Object System.Drawing.Font('Segoe UI', 9)) -Color $textMuted | Out-Null
Add-TextLabel -Parent $summaryPanel -Text (Get-Text -Key 'summary') -Location (New-Object System.Drawing.Point(25, 124)) -Size (New-Object System.Drawing.Size(246, 82)) -Font (New-Object System.Drawing.Font('Segoe UI', 9)) -Color $textSecondary | Out-Null

function Add-LevelMarker {
    param([int]$Y, [string]$Text, [bool]$Active)
    $levelRow = New-Object System.Windows.Forms.Panel
    $levelRow.BackColor = $surfaceRaised
    $levelRow.Location = New-Object System.Drawing.Point(18, ($Y - 5))
    $levelRow.Size = New-Object System.Drawing.Size(264, 34)
    $levelRow.Add_Paint({
        param($sender, $eventArgs)
        $rowBorder = if ($Active) { [System.Drawing.Color]::FromArgb(55, 201, 137) } else { [System.Drawing.Color]::FromArgb(62, 73, 86) }
        $pen = New-Object System.Drawing.Pen($rowBorder, 1)
        try {
            $eventArgs.Graphics.DrawRectangle($pen, 0, 0, $sender.Width - 1, $sender.Height - 1)
        } finally {
            $pen.Dispose()
        }
    }.GetNewClosure())
    $summaryPanel.Controls.Add($levelRow)
    $markerText = if ($Active) { [char]0x25CF } else { [char]0x25CB }
    $markerColor = if ($Active) { [System.Drawing.Color]::FromArgb(55, 201, 137) } else { $textMuted }
    $marker = Add-TextLabel -Parent $levelRow -Text $markerText -Location (New-Object System.Drawing.Point(8, 2)) -Size (New-Object System.Drawing.Size(24, 28)) -Font (New-Object System.Drawing.Font('Segoe UI Symbol', 13)) -Color $markerColor
    $fontStyle = if ($Active) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $textColor = if ($Active) { $textPrimary } else { $textSecondary }
    $fontSize = 9.0
    $levelFont = $null
    while ($fontSize -ge 7.5) {
        $candidate = New-Object System.Drawing.Font('Segoe UI', $fontSize, $fontStyle)
        if ([System.Windows.Forms.TextRenderer]::MeasureText($Text, $candidate).Width -le 244) {
            $levelFont = $candidate
            break
        }
        $candidate.Dispose()
        $fontSize -= 0.5
    }
    if ($null -eq $levelFont) { $levelFont = New-Object System.Drawing.Font('Segoe UI', 7.5, $fontStyle) }
    $levelLabel = Add-TextLabel -Parent $levelRow -Text $Text -Location (New-Object System.Drawing.Point(34, 3)) -Size (New-Object System.Drawing.Size(222, 26)) -Font $levelFont -Color $textColor
    $levelLabel.AutoEllipsis = $false
    $levelLabel.TextAlign = if ($culture -like 'ar*') { 'MiddleRight' } else { 'MiddleLeft' }
    $levelLabel.RightToLeft = $form.RightToLeft
}

Add-LevelMarker -Y 226 -Text ('3 ' + (Get-Text -Key 'detected') + ' - ' + (Get-Text -Key 'light')) -Active ($Level -eq 3)
Add-LevelMarker -Y 270 -Text ('5 ' + (Get-Text -Key 'detected') + ' - ' + (Get-Text -Key 'medium')) -Active ($Level -eq 5)
Add-LevelMarker -Y 314 -Text ('10 ' + (Get-Text -Key 'detected') + ' - ' + (Get-Text -Key 'heavy')) -Active ($Level -eq 10)
if (-not [string]::IsNullOrWhiteSpace($MessageBase64)) {
    Add-TextLabel -Parent $summaryPanel -Text $message -Location (New-Object System.Drawing.Point(25, 385)) -Size (New-Object System.Drawing.Size(246, 70)) -Font (New-Object System.Drawing.Font('Segoe UI', 8.5)) -Color $textSecondary | Out-Null
}

$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Dock = 'None'
$mainPanel.Location = New-Object System.Drawing.Point(300, 0)
$mainPanel.Size = New-Object System.Drawing.Size(620, 478)
$mainPanel.BackColor = $surface
$body.Controls.Add($mainPanel)
$body.Controls.Add($summaryPanel)
$form.Controls.Add($body)

$tabStrip = New-Object System.Windows.Forms.Panel
$tabStrip.Dock = 'None'
$tabStrip.Location = New-Object System.Drawing.Point(0, 0)
$tabStrip.Size = New-Object System.Drawing.Size(620, 34)
$tabStrip.Height = 34
$tabStrip.BackColor = $surface

$actionsTab = New-Object System.Windows.Forms.Button
$actionsTab.Text = Get-Text -Key 'recommended'
$actionsTab.Size = New-Object System.Drawing.Size(142, 34)
$actionsTab.Location = New-Object System.Drawing.Point(0, 0)
$actionsTab.FlatStyle = 'Flat'
$actionsTab.FlatAppearance.BorderSize = 1
$actionsTab.Font = New-Object System.Drawing.Font('Segoe UI', 8.5)
$tabStrip.Controls.Add($actionsTab)

$commandsTab = New-Object System.Windows.Forms.Button
$commandsTab.Text = Get-Text -Key 'allCommands'
$commandsTab.Size = New-Object System.Drawing.Size(142, 34)
$commandsTab.Location = New-Object System.Drawing.Point(142, 0)
$commandsTab.FlatStyle = 'Flat'
$commandsTab.FlatAppearance.BorderSize = 1
$commandsTab.Font = New-Object System.Drawing.Font('Segoe UI', 8.5)
$tabStrip.Controls.Add($commandsTab)

$pageHost = New-Object System.Windows.Forms.Panel
$pageHost.Dock = 'None'
$pageHost.Location = New-Object System.Drawing.Point(0, 34)
$pageHost.Size = New-Object System.Drawing.Size(620, 444)
$pageHost.BackColor = $surface
$mainPanel.Controls.Add($pageHost)
$mainPanel.Controls.Add($tabStrip)

$actions = New-Object System.Windows.Forms.Panel
$actions.Dock = 'Fill'
$actions.BackColor = $surface
$pageHost.Controls.Add($actions)

$commandsPage = New-Object System.Windows.Forms.Panel
$commandsPage.Dock = 'Fill'
$commandsPage.BackColor = $surface
$pageHost.Controls.Add($commandsPage)
Add-TextLabel -Parent $actions -Text (Get-Text -Key 'choose') -Location (New-Object System.Drawing.Point(24, 20)) -Size (New-Object System.Drawing.Size(500, 30)) -Font (New-Object System.Drawing.Font('Segoe UI Semibold', 13)) | Out-Null
Add-TextLabel -Parent $actions -Text (Get-Text -Key 'hint') -Location (New-Object System.Drawing.Point(25, 50)) -Size (New-Object System.Drawing.Size(520, 24)) -Font (New-Object System.Drawing.Font('Segoe UI', 8.5)) -Color $textMuted | Out-Null
$status = Add-TextLabel -Parent $actions -Text (Get-Text -Key 'none') -Location (New-Object System.Drawing.Point(25, 408)) -Size (New-Object System.Drawing.Size(420, 24)) -Font (New-Object System.Drawing.Font('Segoe UI', 8.5)) -Color ([System.Drawing.Color]::FromArgb(105, 196, 151))

function Add-ActionRow {
    param([int]$Index, [int]$Y, [string]$Title, [string]$Description, [string]$ButtonText, [string]$Command, [bool]$Primary = $false)
    $line = New-Object System.Windows.Forms.Panel
    $line.BackColor = $border
    $line.Size = New-Object System.Drawing.Size(568, 1)
    $line.Location = New-Object System.Drawing.Point(24, $Y)
    $actions.Controls.Add($line)
    Add-TextLabel -Parent $actions -Text ('{0:D2}' -f $Index) -Location (New-Object System.Drawing.Point(25, ($Y + 22))) -Size (New-Object System.Drawing.Size(32, 32)) -Font (New-Object System.Drawing.Font('Segoe UI Semibold', 8)) -Color $textMuted | Out-Null
    $rowTitle = Add-TextLabel -Parent $actions -Text $Title -Location (New-Object System.Drawing.Point(80, ($Y + 18))) -Size (New-Object System.Drawing.Size(350, 24)) -Font (New-Object System.Drawing.Font('Segoe UI Semibold', 10)) | Out-Null
    Add-TextLabel -Parent $actions -Text $Description -Location (New-Object System.Drawing.Point(80, ($Y + 42))) -Size (New-Object System.Drawing.Size(350, 34)) -Font (New-Object System.Drawing.Font('Segoe UI', 8)) -Color $textMuted | Out-Null
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $ButtonText
    $button.Size = New-Object System.Drawing.Size(134, 38)
    $button.Location = New-Object System.Drawing.Point(458, ($Y + 22))
    $button.FlatStyle = 'Flat'
    $button.FlatAppearance.BorderSize = 1
    $button.BackColor = if ($Primary) { $accent } else { $surfaceSoft }
    $button.ForeColor = $textPrimary
    $button.FlatAppearance.BorderColor = if ($Primary) { $accent } else { $border }
    $commandToCopy = $Command
    $statusToUpdate = $status
    $buttonToUpdate = $button
    $button.Add_Click({
        [System.Windows.Forms.Clipboard]::SetText($commandToCopy)
        $statusToUpdate.Text = Get-FormattedText -Key 'copied' -Value $commandToCopy
        $buttonToUpdate.Text = 'OK'
    }.GetNewClosure())
    $actions.Controls.Add($button)
}

Add-ActionRow -Index 1 -Y 83 -Title (Get-Text -Key 'checkTitle') -Description (Get-Text -Key 'checkDescription') -ButtonText (Get-Text -Key 'copyCheck') -Command '/chat-cleanup check'
Add-ActionRow -Index 2 -Y 166 -Title (Get-Text -Key 'refreshTitle') -Description (Get-Text -Key 'refreshDescription') -ButtonText (Get-Text -Key 'copyRefresh') -Command '/chat-cleanup refresh'
Add-ActionRow -Index 3 -Y 249 -Title (Get-Text -Key 'nowTitle') -Description (Get-Text -Key 'nowDescription') -ButtonText (Get-Text -Key 'copyNow') -Command '/chat-cleanup now' -Primary $true

$footerLine = New-Object System.Windows.Forms.Panel
$footerLine.BackColor = $border
$footerLine.Size = New-Object System.Drawing.Size(568, 1)
$footerLine.Location = New-Object System.Drawing.Point(24, 386)
$actions.Controls.Add($footerLine)
$continueButton = New-Object System.Windows.Forms.Button
$continueButton.Text = Get-Text -Key 'continue'
$continueButton.Size = New-Object System.Drawing.Size(118, 38)
$continueButton.Location = New-Object System.Drawing.Point(474, 396)
$continueButton.FlatStyle = 'Flat'
$continueButton.BackColor = $surfaceSoft
$continueButton.ForeColor = $textPrimary
$continueButton.FlatAppearance.BorderColor = $border
$continueButton.Add_Click({ $form.Close() }.GetNewClosure())
$actions.Controls.Add($continueButton)

Add-TextLabel -Parent $commandsPage -Text (Get-Text -Key 'commandsTitle') -Location (New-Object System.Drawing.Point(24, 22)) -Size (New-Object System.Drawing.Size(500, 30)) -Font (New-Object System.Drawing.Font('Segoe UI Semibold', 13)) | Out-Null
Add-TextLabel -Parent $commandsPage -Text (Get-Text -Key 'commandsHint') -Location (New-Object System.Drawing.Point(25, 50)) -Size (New-Object System.Drawing.Size(520, 24)) -Font (New-Object System.Drawing.Font('Segoe UI', 8.5)) -Color $textMuted | Out-Null
$commandsStatus = Add-TextLabel -Parent $commandsPage -Text (Get-Text -Key 'commandsStatus') -Location (New-Object System.Drawing.Point(25, 407)) -Size (New-Object System.Drawing.Size(500, 24)) -Font (New-Object System.Drawing.Font('Segoe UI', 8.5)) -Color ([System.Drawing.Color]::FromArgb(105, 196, 151))

function Add-CommandRow {
    param([int]$Y, [string]$Command, [string]$Description)
    Add-TextLabel -Parent $commandsPage -Text $Command -Location (New-Object System.Drawing.Point(25, $Y)) -Size (New-Object System.Drawing.Size(400, 22)) -Font (New-Object System.Drawing.Font('Consolas', 9)) | Out-Null
    Add-TextLabel -Parent $commandsPage -Text $Description -Location (New-Object System.Drawing.Point(25, ($Y + 20))) -Size (New-Object System.Drawing.Size(390, 30)) -Font (New-Object System.Drawing.Font('Segoe UI', 8)) -Color $textMuted | Out-Null
    $copyButton = New-Object System.Windows.Forms.Button
    $copyButton.Text = $copyLabel
    $copyButton.Size = New-Object System.Drawing.Size(92, 32)
    $copyButton.Location = New-Object System.Drawing.Point(500, ($Y + 3))
    $copyButton.FlatStyle = 'Flat'
    $copyButton.BackColor = $surfaceSoft
    $copyButton.ForeColor = $textPrimary
    $copyButton.FlatAppearance.BorderColor = $border
    $commandToCopy = $Command
    $statusToUpdate = $commandsStatus
    $buttonToUpdate = $copyButton
    $copyButton.Add_Click({
        [System.Windows.Forms.Clipboard]::SetText($commandToCopy)
        $statusToUpdate.Text = Get-FormattedText -Key 'copied' -Value $commandToCopy
        $buttonToUpdate.Text = 'OK'
    }.GetNewClosure())
    $commandsPage.Controls.Add($copyButton)
}

Add-CommandRow -Y 82 -Command '/chat-cleanup' -Description (Get-Text -Key 'guidedCommand')
Add-CommandRow -Y 134 -Command '/chat-cleanup check' -Description (Get-Text -Key 'checkCommand')
Add-CommandRow -Y 186 -Command '/chat-cleanup preview' -Description (Get-Text -Key 'previewCommand')
Add-CommandRow -Y 238 -Command '/chat-cleanup status' -Description (Get-Text -Key 'statusCommand')
Add-CommandRow -Y 290 -Command '/chat-cleanup refresh' -Description (Get-Text -Key 'refreshCommand')
Add-CommandRow -Y 342 -Command '/chat-cleanup now' -Description (Get-Text -Key 'nowCommand')

$setTabColors = {
    param([bool]$CommandsSelected)
    $selectedBack = $accent
    $unselectedBack = $surfaceSoft
    $selectedBorder = $accent
    $unselectedBorder = $border
    $actionsTab.BackColor = if ($CommandsSelected) { $unselectedBack } else { $selectedBack }
    $actionsTab.ForeColor = if ($CommandsSelected) { $textSecondary } else { [System.Drawing.Color]::White }
    $actionsTab.FlatAppearance.BorderColor = if ($CommandsSelected) { $unselectedBorder } else { $selectedBorder }
    $commandsTab.BackColor = if ($CommandsSelected) { $selectedBack } else { $unselectedBack }
    $commandsTab.ForeColor = if ($CommandsSelected) { [System.Drawing.Color]::White } else { $textSecondary }
    $commandsTab.FlatAppearance.BorderColor = if ($CommandsSelected) { $selectedBorder } else { $unselectedBorder }
    $actions.Visible = -not $CommandsSelected
    $commandsPage.Visible = $CommandsSelected
}.GetNewClosure()
$actionsTab.Add_Click({ & $setTabColors $false }.GetNewClosure())
$commandsTab.Add_Click({ & $setTabColors $true }.GetNewClosure())
& $setTabColors $false

$layoutUi = {
    $bodyWidth = [Math]::Max(0, $body.ClientSize.Width)
    $bodyHeight = [Math]::Max(0, $body.ClientSize.Height)
    $summaryWidth = [Math]::Min(300, $bodyWidth)
    $mainWidth = [Math]::Max(0, $bodyWidth - $summaryWidth)
    $summaryPanel.Bounds = New-Object System.Drawing.Rectangle(0, 0, $summaryWidth, $bodyHeight)
    $mainPanel.Bounds = New-Object System.Drawing.Rectangle($summaryWidth, 0, $mainWidth, $bodyHeight)
    $tabStrip.Bounds = New-Object System.Drawing.Rectangle(0, 0, $mainWidth, 34)
    $pageHost.Bounds = New-Object System.Drawing.Rectangle(0, 34, $mainWidth, [Math]::Max(0, $bodyHeight - 34))
}.GetNewClosure()
$layoutRoot = {
    $clientWidth = [Math]::Max(0, $form.ClientSize.Width)
    $clientHeight = [Math]::Max(0, $form.ClientSize.Height)
    $header.Bounds = New-Object System.Drawing.Rectangle(0, 0, $clientWidth, 92)
    $body.Bounds = New-Object System.Drawing.Rectangle(0, 92, $clientWidth, [Math]::Max(0, $clientHeight - 92))
    & $layoutUi
}.GetNewClosure()
$body.Add_SizeChanged({ & $layoutUi }.GetNewClosure())
$form.Add_SizeChanged({ & $layoutRoot }.GetNewClosure())

[void]$form.Handle
$null = [ChatCleanupConsole]::UseDarkTitleBar($form.Handle)
$null = [ChatCleanupConsole]::SetWindowIcon($form.Handle, $iconState.Icon.Handle)
$consoleWindow = [ChatCleanupConsole]::GetConsoleWindow()
if ($consoleWindow -ne [IntPtr]::Zero) {
    [ChatCleanupConsole]::HideFromTaskbar($consoleWindow)
    [void][ChatCleanupConsole]::ShowWindow($consoleWindow, 0)
}
$formToShow = $form
$form.Add_Shown({
    & $layoutRoot
    & $layoutUi
    & $positionBadge
    [void][ChatCleanupConsole]::ShowWindow($formToShow.Handle, 5)
    [void][ChatCleanupConsole]::SetForegroundWindow($formToShow.Handle)
}.GetNewClosure())
[void]$form.ShowDialog()
$iconState.Icon.Dispose()
$iconState.Bitmap.Dispose()
