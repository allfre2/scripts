# Run as Administrator

# Set-ExecutionPolicy Bypass -Scope CurrentUser -Force

# Load configuration file

$config = Get-Content ".\config.json" -Raw | ConvertFrom-Json

$repoDir = Join-Path $HOME $config.Git.SourceDir

Get-ChildItem $repoDir -Directory | Where-Object { Test-Path (Join-Path $_.FullName ".git") } | ForEach-Object {
    Write-Host "Updating repository: $($_.Name)" -ForegroundColor Cyan
    Push-Location $_.FullName
    git pull --all
    Pop-Location
}
