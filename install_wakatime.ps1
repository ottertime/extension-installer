# Extension/Plugin identifiers
$vscodeExt    = "WakaTime.vscode-wakatime"
$jetbrainsPid = "com.wakatime.intellij.plugin"

# Get WakaTime configuration from environment variables
$apiKey = $env:OTTERTIME_API_KEY
$apiUrl = $env:OTTERTIME_API_URL

# Exit if required environment variables are not set
if (-not $apiKey -or -not $apiUrl) {
    Write-Host "Error: OTTERTIME_API_KEY and OTTERTIME_API_URL environment variables must be set" -ForegroundColor Red
    exit 1
}

# Configure WakaTime settings
$configPath    = "$env:USERPROFILE\.wakatime.cfg"
$configContent = @"
[settings]
api_key = $apiKey
api_url = $apiUrl
"@

# Display welcome message
try {
    $markdown = "**Welcome to OtterTime!**"
    $styled   = ($markdown | ConvertFrom-Markdown -AsVT100EncodedString).VT100EncodedString
    Write-Host $styled
} catch {
    Write-Host "Welcome to OtterTime!"
}
Write-Host "If you have any issues with this script, please file an issue at https://github.com/ottertime/extension-installer/issues.`n" -ForegroundColor DarkGray

# Write configuration file
Set-Content -Path $configPath -Value $configContent
Write-Host "✓ Wrote WakaTime config!" -ForegroundColor Green

# Install for VS Code
if (Get-Command code -ErrorAction SilentlyContinue) {
    Write-Host "`n→ Installing WakaTime for VSCode..." -ForegroundColor Green
    code --install-extension $vscodeExt --force
    Write-Host
} else {
    Write-Host "VSCode CLI 'code' not found; skipping." -ForegroundColor DarkGray
}

# Install for Trae AI
if (Get-Command trae -ErrorAction SilentlyContinue) {
    Write-Host "`n→ Installing WakaTime for Trae..." -ForegroundColor Green
    trae --install-extension $vscodeExt --force
    Write-Host
} else {
    Write-Host "Trae CLI 'trae' not found; skipping." -ForegroundColor DarkGray
}

# Install for Cursor
if (Get-Command cursor -ErrorAction SilentlyContinue) {
    Write-Host "`n→ Installing WakaTime for Cursor..." -ForegroundColor Green
    cursor --install-extension $vscodeExt --force
    Write-Host
} else {
    Write-Host "Cursor CLI 'cursor' not found; skipping." -ForegroundColor DarkGray
}

# Install for Windsurf
if (Get-Command windsurf -ErrorAction SilentlyContinue) {
    Write-Host "`n→ Installing WakaTime for Windsurf..." -ForegroundColor Green
    windsurf --install-extension $vscodeExt --force
    Write-Host
} else {
    Write-Host "Windsurf CLI 'windsurf' not found; skipping." -ForegroundColor DarkGray
}

# Install for JetBrains IDEs (incl. Toolbox)
$pluginId        = $jetbrainsPid
$jetbrainsRoot   = "$env:APPDATA\JetBrains"
$pluginRepoQuery = "https://plugins.jetbrains.com/pluginManager?action=download&id=$pluginId&build="

Write-Host "`n→ Installing WakaTime plugin for JetBrains IDEs..." -ForegroundColor Green

# Scan standard JetBrains config
if (Test-Path $jetbrainsRoot) {
    Get-ChildItem -Path $jetbrainsRoot -Directory | ForEach-Object {
        $ideConfig = $_.FullName
        $pluginsDir = Join-Path $ideConfig "plugins"
        if (-not (Test-Path $pluginsDir)) {
            New-Item -ItemType Directory -Path $pluginsDir | Out-Null
        }
        # Download and extract plugin
        $tempZip = [System.IO.Path]::GetTempFileName()
        Invoke-WebRequest -Uri $pluginRepoQuery -OutFile $tempZip -UseBasicParsing
        $targetDir = Join-Path $pluginsDir "WakaTime"
        if (Test-Path $targetDir) { Remove-Item $targetDir -Recurse -Force }
        Expand-Archive -Path $tempZip -DestinationPath $targetDir -Force
        Remove-Item $tempZip -Force
        Write-Host "  ✓ Installed in $($_.Name)"
    }
} else {
    Write-Host "No JetBrains config directory found at $jetbrainsRoot; skipping." -ForegroundColor DarkGray
}

Write-Host "`n✓ All installations complete! Please restart your IDEs to activate WakaTime." -ForegroundColor Green
