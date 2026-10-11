. ".\Common.ps1"

function Enable-WindowsCapabilities {
    $config = Get-Config

    # Compatibility

    # $WindowsMinVersion = [version]$config.Windows.MinVersion
    $PSMinVersion = [version]$config.Windows.PowerShell.MinVersion

    if ($PSVersionTable.PSVersion -lt $PSMinVersion) {
        Write-Error "Minimum PowerShell version required: $PSMinVersion. Current: $($PSVersionTable.PSVersion)"
        exit 1
    }

    # Enable missing features

    Write-Host "Checking required Windows features ..."

    foreach ($feature in $config.Windows.OptionalFeatures) {
    
        $feature = Get-WindowsCapability -Online | Where-Object Name -like $feature
    
        if ($feature.State -eq "NotPresent") {
            Write-Host "Enabling feature: $feature ..."
            Add-WindowsCapability -Online -Name $feature
        }
    }
}

function Install-Apps {
    $config = Get-Config

    Write-Host "Installing applications ..."

    winget --version
    winget source update

    foreach ($app in $config.Apps) {
        Write-Host "Installing $app..."
        winget install --id $app --silent --accept-source-agreements --accept-package-agreements
    }    

    Update-Path
}

Set-Alias -Name Enable-WindowsCapabilities -Value Enable-WindowsCapabilities
Set-Alias -Name Install-Apps -Value Install-Apps
