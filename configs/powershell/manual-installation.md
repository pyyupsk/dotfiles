# Manual Installation Guide

This guide provides instructions for manually installing and configuring the components used in the PowerShell setup script. Follow these steps to set up your PowerShell environment with the necessary tools and modules.

## 1. Check for Administrative Privileges

Ensure that you are running the PowerShell session as an administrator. Some installations require elevated privileges.

## 2. Install Chocolatey

1. **Download and Install Chocolatey**

    Open PowerShell as an administrator and execute the following command:

    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    ```

2. **Verify Installation**

    To check if Chocolatey is installed correctly, run:

    ```powershell
    choco --version
    ```

## 3. Install PowerShell Modules

### Install Modules Using PowerShell

Execute the following commands in PowerShell to install the required modules:

```powershell
Install-Module -Name PSFzf -Scope CurrentUser -Force
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name Terminal-Icons -Repository PSGallery -Force
Install-Module -Name PowerType -AllowPrerelease -Force
```

### Install Oh-My-Posh Using Chocolatey

1. **Install Oh-My-Posh**

    Run the following command in PowerShell to install Oh-My-Posh:

    ```powershell
    choco install oh-my-posh -y -f
    ```

## 4. Configure PowerShell Profile

1. **Locate PowerShell Profile**

    Check if your PowerShell profile exists:

    ```powershell
    $ProfilePath = $PROFILE.CurrentUserAllHosts
    ```

    If the file does not exist, create it:

    ```powershell
    if (-not (Test-Path -Path $ProfilePath)) {
        New-Item -Path $ProfilePath -ItemType File -Force | Out-Null
    }
    ```

2. **Download and Configure Profile Script**

    Download the profile script and save it to your profile path:

    ```powershell
    $profileScript = "https://github.com/pyyupsk/dotfiles/raw/main/configs/powershell/profile.ps1"
    Invoke-WebRequest -Uri $profileScript -OutFile $ProfilePath -UseBasicParsing | Out-Null
    ```

## 5. Configure Oh-My-Posh Theme

1. **Find or Create Theme Path**

    Ensure that the theme directory exists:

    ```powershell
    $themePath = "$env:POSH_THEMES_PATH\pyyupsk.omp.json"
    if (-not (Test-Path -Path $env:POSH_THEMES_PATH)) {
        New-Item -Path $env:POSH_THEMES_PATH -ItemType Directory -Force | Out-Null
    }
    ```

2. **Download and Save Theme Script**

    Download the theme script and save it to the theme path:

    ```powershell
    $themeScript = "https://github.com/pyyupsk/dotfiles/raw/main/configs/powershell/pyyupsk.omp.json"
    Invoke-WebRequest -Uri $themeScript -OutFile $themePath -UseBasicParsing | Out-Null
    ```

## 6. Restart PowerShell

To apply all changes, restart your PowerShell session:

```powershell
Start-Process pwsh -NoNewWindow -Wait
```
