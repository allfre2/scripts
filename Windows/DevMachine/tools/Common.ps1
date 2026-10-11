function Update-Path {
    # Refresh Path environment variable
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Get-Config {
    param (
        $config = $script:config
    )

    if (-not $config) {
        $configFile = Join-Path $PSScriptRoot "..\config.json"
        if (Test-Path $configFile) {
            $config = Get-Content $configFile -Raw | ConvertFrom-Json
        }
    }

    return $config
}

Set-Alias -Name Update-Path -Value Update-Path
Set-Alias -Name Get-Config -Value Get-Config
