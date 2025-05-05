# Extension/Plugin identifiers
$vscodeExt = "WakaTime.vscode-wakatime"
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
$configPath = "$env:USERPROFILE\.wakatime.cfg"
$configContent = @"
[settings]
api_key = $apiKey
api_url = $apiUrl
"@

# Not all terminals support the bold style. Instead of erroring on these terminals, just display plain text.
try {
    $markdown = "**Welcome to OtterTime!**"
    $styled = ($markdown | ConvertFrom-Markdown -AsVT100EncodedString).VT100EncodedString
    Write-Host $styled
} catch {
    Write-Host "Welcome to OtterTime!"
}
Write-Host "If you have any issues with this script, please file an issue at https://github.com/ottertime/extension-installer/issues.`n" -ForegroundColor DarkGray

Set-Content -Path $configPath -Value $configContent
Write-Host "✓ Wrote WakaTime config!" -ForegroundColor Green

# Install for VS Code
if (Get-Command code -ErrorAction SilentlyContinue) {
    Write-Host "`n→ Installing WakaTime for VSCode..." -ForegroundColor Green
    code --install-extension $vscodeExt --force
    Write-Host
}
else {
    Write-Host "VSCode CLI 'code' not found; skipping." -ForegroundColor DarkGray
}

# Install for Trae AI
if (Get-Command trae -ErrorAction SilentlyContinue) {
    Write-Host "`n→ Installing WakaTime for Trae..." -ForegroundColor Green
    trae --install-extension $vscodeExt --force
    Write-Host
}
else {
    Write-Host "Trae CLI 'trae' not found; skipping." -ForegroundColor DarkGray
}

# Install for Cursor
if (Get-Command cursor -ErrorAction SilentlyContinue) {
    Write-Host "`n→ Installing WakaTime for Cursor..." -ForegroundColor Green
    cursor --install-extension $vscodeExt --force
    Write-Host
}
else {
    Write-Host "Cursor CLI 'cursor' not found; skipping." -ForegroundColor DarkGray
}

# Install for Windsurf
if (Get-Command windsurf -ErrorAction SilentlyContinue) {
    Write-Host "`n→ Installing WakaTime for Windsurf..." -ForegroundColor Green
    windsurf --install-extension $vscodeExt --force
    Write-Host
}
else {
    Write-Host "Windsurf CLI 'windsurf' not found; skipping." -ForegroundColor DarkGray
}

# Install for JetBrains IDEs
$ideExes = @(
    "idea64.exe", "pycharm64.exe", "clion64.exe", "goland64.exe",
    "webstorm64.exe", "rider64.exe", "datagrip64.exe",
    "phpstorm64.exe", "rubymine64.exe", "appcode64.exe"
)

$jetbrainsFound = $false
foreach ($exe in $ideExes) {
    $cmd = Get-Command $exe -ErrorAction SilentlyContinue
    if ($cmd) {
        $jetbrainsFound = $true
        Write-Host "`n→ Installing WakaTime plugin in $exe..." -ForegroundColor Green
        & $cmd.Source installPlugins $jetbrainsPid
    }
}

if (-not $jetbrainsFound) {
    Write-Host "No JetBrains IDEs found; skipping." -ForegroundColor DarkGray
}

Write-Host "`n✓ Installation complete!" -ForegroundColor Green
Write-Host "Please restart your IDEs for changes to take effect."
