. "$PSScriptRoot\Common.ps1"

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

    foreach ($featurePattern in $config.Windows.OptionalFeatures) {
        $filter = if ($featurePattern.EndsWith("*")) { $featurePattern } else { "$featurePattern*" }
        $capability = Get-WindowsCapability -Online | Where-Object Name -like $filter
    
        if ($capability -and $capability.State -ne "Installed") {
            Write-Host "Enabling feature: $($capability.Name) ..."
            Add-WindowsCapability -Online -Name $capability.Name
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

