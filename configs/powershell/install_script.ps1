# Logging function
function Write-Log {
    param (
        [string]$Message,
        [string]$Status = "INFO",
        [string]$LogFile = "install_log.txt"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - [$Status] - $Message"
    Add-Content -Path $LogFile -Value $logMessage
    
    switch ($Status) {
        "INFO" { Write-Host $logMessage -ForegroundColor White }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        default { Write-Host $logMessage -ForegroundColor White }
    }
}

# Check admin privileges
Write-Log "Checking admin privileges..." "INFO"
function Check-IsElevated {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    return $identity.Groups -match "S-1-5-32-544"
}

if (-not (Check-IsElevated)) {
    Write-Log "Please run this script as an administrator." "ERROR"
    Exit
}

# Log start
Write-Log "Script execution started." "INFO"

# Find or create PowerShell profile
Write-Log "Finding PowerShell profile..." "INFO"
$ProfilePath = $PROFILE.CurrentUserAllHosts
if (-not (Test-Path -Path $ProfilePath)) {
    New-Item -Path $ProfilePath -ItemType File -Force | Out-Null
    Write-Log "Created PowerShell profile at $ProfilePath." "SUCCESS"
} else {
    Write-Log "PowerShell profile located at $ProfilePath." "SUCCESS"
}

# Check and install Chocolatey
Write-Log "Checking Chocolatey..." "INFO"
if (-not (Get-Command -Name choco -ErrorAction SilentlyContinue)) {
    Write-Log "Chocolatey not found, installing..." "INFO"
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    if (-not (Get-Command -Name choco -ErrorAction SilentlyContinue)) {
        Write-Log "Chocolatey not found after install." "ERROR"
        exit 1
    }
    Write-Log "Chocolatey installed." "SUCCESS"
} else {
    Write-Log "Chocolatey already installed." "SUCCESS"
}

# Install PowerShell modules
$modules = @("PSFzf", "PSReadLine", "Terminal-Icons", "PowerType")
foreach ($module in $modules) {
    try {
        Write-Log "Installing $module module..." "INFO"
        Install-Module -Name $module -Scope CurrentUser -Force -AllowPrerelease -SkipPublisherCheck
        Write-Log "$module module installed." "SUCCESS"
    }
    catch {
        Write-Log "Failed to install $module module: $_" "ERROR"
    }
}

# Install Oh-My-Posh
try {
    Write-Log "Setting execution policy and installing Oh-My-Posh..." "INFO"
    Start-Process pwsh -Verb runAs -ArgumentList "-Command choco install oh-my-posh -y -f" -Wait
    Write-Log "Oh-My-Posh installed." "SUCCESS"
}
catch {
    Write-Log "Failed to install Oh-My-Posh: $_" "ERROR"
}

# Download profile script and theme script
$profileScript = "https://github.com/pyyupsk/dotfiles/raw/main/configs/powershell/profile.ps1"
try {
    Write-Log "Downloading profile script from $profileScript..." "INFO"
    Invoke-WebRequest -Uri $profileScript -OutFile $ProfilePath -UseBasicParsing | Out-Null
    Write-Log "Profile script written to $ProfilePath." "SUCCESS"
}
catch {
    Write-Log "Failed to download profile script: $_" "ERROR"
}

# Write Oh-My-Posh style
$themeScript = "https://github.com/pyyupsk/dotfiles/raw/main/configs/powershell/pyyupsk.omp.json"
$themePath = "$env:POSH_THEMES_PATH\pyyupsk.omp.json"
if (-not (Test-Path -Path $env:POSH_THEMES_PATH)) {
    try {
        Write-Log "Theme path not found, creating new theme path..." "INFO"
        New-Item -Path $env:POSH_THEMES_PATH -ItemType Directory -Force | Out-Null
        Write-Log "Theme path created at $env:POSH_THEMES_PATH." "SUCCESS"
    }
    catch {
        Write-Log "Failed to create theme path: $_" "ERROR"
    }
}

try {
    Write-Log "Downloading theme script from $themeScript..." "INFO"
    Invoke-WebRequest -Uri $themeScript -OutFile $themePath -UseBasicParsing | Out-Null
    Write-Log "Theme script written to $themePath." "SUCCESS"
}
catch {
    Write-Log "Failed to download theme script: $_" "ERROR"
}

# Log completion
Write-Log "Script execution completed." "INFO"
Write-Log "You should now have a customized PowerShell terminal with enhanced features and a stylish prompt after restarting PowerShell." "SUCCESS"

# Restart PowerShell
Write-Log "Restarting PowerShell..." "INFO"
Start-Process pwsh -NoNewWindow -Wait
