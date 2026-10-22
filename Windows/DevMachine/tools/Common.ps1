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
            $script:config = Get-Content $configFile -Raw | ConvertFrom-Json
            $config = $script:config
        } else {
            Write-Error "Config file not found: $configFile"
        }
    }

    return $config
}
