param(
    [switch]$apps,
    [switch]$repos
)

# Run as Administrator

# Set-ExecutionPolicy Bypass -Scope CurrentUser -Force

# Import tools

. "$PSScriptRoot\tools\Apps.ps1"
. "$PSScriptRoot\tools\Git.ps1"

# Install Applications

if ($apps) {
    Enable-WindowsCapabilities
    Install-Apps
}

if ($repos) {
    Initialize-Git
}

