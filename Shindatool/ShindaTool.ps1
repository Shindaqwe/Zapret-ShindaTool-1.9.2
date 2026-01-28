﻿# Добавляем необходимые сборки для Windows Forms
Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
Add-Type -AssemblyName System.Drawing -ErrorAction Stop

# ================= НАСТРОЙКИ =================
$TelegramLink = "https://t.me/shindaqwe"
$DonateLink   = "https://dalink.to/shindaqwe"
$GitHubVersionUrl = "https://raw.githubusercontent.com/USER/REPO/main/version.txt"
$GitHubReleaseUrl = "https://github.com/USER/REPO/releases/latest"

$ConfigPath = Join-Path $PSScriptRoot "config.json"
$ChangelogPath = Join-Path $PSScriptRoot "CHANGELOG.txt"

$alts = @(
    "general",
    "general (ALT)",
    "general (ALT2)",
    "general (ALT3)",
    "general (ALT4)",
    "general (ALT5)",
    "general (ALT6)",
    "general (ALT7)",
    "general (ALT8)",
    "general (ALT9)",
    "general (ALT10)",
    "general (ALT11)",
    "general (FAKE TLS AUTO)",
    "general (FAKE TLS AUTO ALT)",
    "general (FAKE TLS AUTO ALT2)",
    "general (FAKE TLS AUTO ALT3)",
    "general (SIMPLE FAKE)",
    "general (SIMPLE FAKE ALT)",
    "general (SIMPLE FAKE ALT2)"
)

# ================= КОНФИГ =================
$Config = @{
    lastAlt = "general"
    theme   = "dark"
    version = "1.0.0"
}

if (Test-Path $ConfigPath) {
    try {
        $jsonContent = Get-Content $ConfigPath -Raw -ErrorAction Stop
        $Config = $jsonContent | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        Write-Warning "Ошибка загрузки конфига: $_"
    }
}

# ================= ФОРМА =================
$form = New-Object System.Windows.Forms.Form
$form.Text = "Shinda Tool"
$form.Size = New-Object System.Drawing.Size(420, 520)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Инициализация переменных
$controls = New-Object System.Collections.ArrayList
$combo = $null
$runBtn = $null
$dark = $Config.theme -eq "dark"

# ================= ТЕМА =================
function ApplyTheme {
    if ($dark) {
        # Темная тема
        $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
        $form.ForeColor = [System.Drawing.Color]::White
        
        foreach ($c in $controls) {
            if ($c -ne $null) {
                $c.BackColor = [System.Drawing.Color]::FromArgb(43, 43, 43)
                $c.ForeColor = [System.Drawing.Color]::White
                
                # Особые настройки для разных типов контролов
                if ($c -is [System.Windows.Forms.Button]) {
                    $c.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                    $c.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
                    $c.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
                    $c.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
                }
                elseif ($c -is [System.Windows.Forms.ComboBox]) {
                    $c.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                }
            }
        }
    } else {
        # Светлая тема
        $form.BackColor = [System.Drawing.Color]::White
        $form.ForeColor = [System.Drawing.Color]::Black
        
        foreach ($c in $controls) {
            if ($c -ne $null) {
                $c.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
                $c.ForeColor = [System.Drawing.Color]::Black
                
                if ($c -is [System.Windows.Forms.Button]) {
                    $c.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
                }
                elseif ($c -is [System.Windows.Forms.ComboBox]) {
                    $c.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
                }
            }
        }
    }
}

# ================= ALT =================
$combo = New-Object System.Windows.Forms.ComboBox
$combo.Location = New-Object System.Drawing.Point(40, 40)
$combo.Size = New-Object System.Drawing.Size(320, 30)
$combo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$combo.Items.AddRange($alts)
$combo.SelectedItem = $Config.lastAlt
$form.Controls.Add($combo)
$null = $controls.Add($combo)

# ================= ЗАПУСК =================
$runBtn = New-Object System.Windows.Forms.Button
$runBtn.Text = "▶ Запустить"
$runBtn.Location = New-Object System.Drawing.Point(40, 90)
$runBtn.Size = New-Object System.Drawing.Size(320, 40)
$runBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
$form.Controls.Add($runBtn)
$null = $controls.Add($runBtn)

function CheckAlt {
    if ($combo.SelectedItem -ne $null) {
        $file = Join-Path $PSScriptRoot "$($combo.SelectedItem).bat"
        $runBtn.Enabled = Test-Path $file
    }
    else {
        $runBtn.Enabled = $false
    }
}

$combo.Add_SelectedIndexChanged({
    CheckAlt
})

$runBtn.Add_Click({
    if ($combo.SelectedItem -ne $null) {
        $batFile = Join-Path $PSScriptRoot "$($combo.SelectedItem).bat"
        if (Test-Path $batFile) {
            try {
                Start-Process $batFile -WindowStyle Hidden
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Ошибка запуска: $_", "Ошибка", "OK", "Error")
            }
        }
        
        # Сохраняем конфиг
        $Config.lastAlt = $combo.SelectedItem
        $Config.theme = if ($dark) { "dark" } else { "light" }
        try {
            $Config | ConvertTo-Json | Set-Content $ConfigPath -ErrorAction Stop
        }
        catch {
            Write-Warning "Ошибка сохранения конфига: $_"
        }
    }
})

# ================= КНОПКИ =================
function AddBtn($text, $y, $action) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $text
    $b.Location = New-Object System.Drawing.Point(40, $y)
    $b.Size = New-Object System.Drawing.Size(320, 35)
    $b.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
    $b.Add_Click($action)
    $form.Controls.Add($b)
    $null = $controls.Add($b)
}

AddBtn "🔧 Сервис" 150 { 
    $serviceBat = Join-Path $PSScriptRoot "service.bat"
    if (Test-Path $serviceBat) {
        Start-Process $serviceBat -WindowStyle Hidden
    }
    else {
        [System.Windows.Forms.MessageBox]::Show("Файл service.bat не найден!", "Ошибка", "OK", "Error")
    }
}

AddBtn "☀🌙 Смена темы" 195 {
    $script:dark = -not $dark
    ApplyTheme
}

AddBtn "💚 Донат" 240 { 
    try {
        Start-Process $DonateLink
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Не удалось открыть ссылку: $_", "Ошибка", "OK", "Error")
    }
}

AddBtn "✈ Telegram / Обновления" 285 { 
    try {
        Start-Process $TelegramLink
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Не удалось открыть ссылку: $_", "Ошибка", "OK", "Error")
    }
}

AddBtn "📄 Лог обновлений" 330 {
    if (!(Test-Path $ChangelogPath)) {
        try {
            "Changelog`n==========" | Set-Content $ChangelogPath -ErrorAction Stop
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Не удалось создать файл лога: $_", "Ошибка", "OK", "Error")
            return
        }
    }
    
    try {
        Start-Process notepad.exe -ArgumentList $ChangelogPath
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Не удалось открыть лог: $_", "Ошибка", "OK", "Error")
    }
}

# ================= АВТООБНОВЛЕНИЕ =================
try {
    $remote = Invoke-RestMethod $GitHubVersionUrl -ErrorAction SilentlyContinue
    if ($remote -ne $Config.version) {
        $result = [System.Windows.Forms.MessageBox]::Show(
            "Доступна новая версия: $remote`n`nХотите открыть страницу загрузки?",
            "Обновление",
            "YesNo",
            "Information"
        )
        
        if ($result -eq "Yes") {
            Start-Process $GitHubReleaseUrl
        }
    }
} catch {
    # Игнорируем ошибки проверки обновлений
}

# Применяем тему и проверяем доступность BAT файла
ApplyTheme
CheckAlt

# Показываем форму
try {
    [System.Windows.Forms.Application]::Run($form)
}
catch {
    [System.Windows.Forms.MessageBox]::Show("Критическая ошибка: $_", "Ошибка", "OK", "Error")
}