# Measure fnm env execution time
Measure-Command { fnm env --use-on-cd | Out-String | Invoke-Expression }

# Import essential modules and set options
Import-Module PSReadLine
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Import Terminal-Icons module asynchronously
Start-Job { Import-Module Terminal-Icons }

# Enable PowerType
Enable-PowerType
Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView

# Set console encoding
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Initialize Oh-My-Posh asynchronously
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\pyyupsk.omp.json" | Invoke-Expression

# Clear console on startup
Clear-Host

# Define aliases
Set-Alias lt "tree"
Set-Alias ll "ls"
Set-Alias l "ls"
Set-Alias nf "New-Item -ItemType File -Force"
Set-Alias nd mkdir
Set-Alias rm "Remove-Item -Force"
Set-Alias rd "Remove-Item -Recurse -Force"
Set-Alias vim "nvim"
Set-Alias c "Clear-Host"
Set-Alias g "git"

# Define functions
function search {
    param(
        [Parameter(Mandatory = $true)]
        [string]$query
    )
    Start-Process "https://www.google.com/search?q=$query"
    Write-Host "[INFO]" -ForegroundColor Green -NoNewline
    Write-Host " Searching in browser" -ForegroundColor White
}

function work {
    Set-Location "E:\Coding" | Out-Null
}

function update-posh {
    try {
        winget upgrade JanDeDobbeleer.OhMyPosh -s winget
    }
    catch {
        Write-Host "[ERROR]" -ForegroundColor Red -NoNewline
        Write-Host " Update-Posh failed" -ForegroundColor White
    }
}

function rmrf {
    param(
        [Parameter(Mandatory = $true)]
        [string]$path
    )
    
    $confirmation = Read-Host "Are you sure you want to delete $path? [y/n]"
    if ($confirmation -eq 'y') {
        Remove-Item -Recurse -Force $path
    }
}

function which {
    param(
        [Parameter(Mandatory = $true)]
        [string]$command
    )
    
    Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
