param(
    [switch]$save,
    [switch]$apply
)

# Run as Administrator

# Set-ExecutionPolicy Bypass -Scope Process -Force

# Load configuration file

$config = Get-Content ".\config.json" -Raw | ConvertFrom-Json

$repoDir = Join-Path $HOME $config.Git.SourceDir
$stashDir = Join-Path (Get-Location).Path "stash"

if (-not (Test-Path $stashDir)) {
    New-Item -ItemType Directory -Path $stashDir -Force | Out-Null
}

if ($save) {
    Get-ChildItem $repoDir -Directory | Where-Object { Test-Path (Join-Path $_.FullName ".git") } | ForEach-Object {
        Write-Host "Saving stash 0 for repository: $($_.Name)" -ForegroundColor Cyan

        Push-Location $_.FullName

        $patchFile = "$stashDir\$($_.Name).diff"
    
        git diff | Out-File -Encoding utf8 "$patchFile"

        if ((Get-Item $patchFile).Length -eq 0) {
            Remove-Item $patchFile -Force
            Write-Host "No stash 0 found for repository: $($_.Name)" -ForegroundColor Yellow
        }

        Pop-Location
    }
}

if ($apply) {
    Get-ChildItem $repoDir -Directory | Where-Object { Test-Path (Join-Path $_.FullName ".git") } | ForEach-Object {
        Write-Host "Applying stash 0 for repository: $($_.Name)" -ForegroundColor Cyan

        Push-Location $_.FullName

        $patchFile = "$stashDir\$($_.Name).diff"

        if (Test-Path $patchFile) {
            git apply "$patchFile"
        }

        Pop-Location
    }
}
