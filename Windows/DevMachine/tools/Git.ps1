. "$PSScriptRoot\Common.ps1"

function Get-GithubHeaders {
    $config = Get-Config
    return @{
        Accept                 = "application/vnd.github+json"
        Authorization          = "Bearer $($config.Git.Token)"
        "X-GitHub-Api-Version" = $config.Git.ApiVersion
    }
}

function Install-GithubKeys {
    $config = Get-Config

    Write-Host "Configuring ssh keys ..."

    Set-Service -Name ssh-agent -StartupType Automatic
    Start-Service ssh-agent -ErrorAction SilentlyContinue

    # Use the standard OpenSSH default key name "id_ed25519" so all SSH clients discover it
    # This saves time from creating a config file but makes it harder to manage multiple keys

    $keyName = "id_ed25519"
    $keyTitle = "$env:COMPUTERNAME-$([System.DateTimeOffset]::new((Get-Date)).ToUnixTimeSeconds())"
    $sshDir = Join-Path $HOME ".ssh"

    if (-not (Test-Path -Path $sshDir -PathType Container)) {
        New-Item -ItemType Directory -Path $sshDir -Force
    }

    $keyFile = Join-Path $sshDir $keyName

    # Remove existing key from ssh-agent and ~/.ssh to prevent overwrite prompts

    if (Test-Path -Path "$keyFile.pub" -PathType Leaf) {
        ssh-add -d $keyFile 2>$null
        Remove-Item "$keyFile.pub" -Force -ErrorAction SilentlyContinue
    }

    if (Test-Path -Path $keyFile -PathType Leaf) {
        Remove-Item $keyFile -Force -ErrorAction SilentlyContinue
    }

    ssh-keygen -q -t ed25519 -f $keyFile -N '""'

    $headers = Get-GithubHeaders

    $publicKey = Get-Content "$keyFile.pub" -Raw

    $body = @{
        title = $keyTitle
        key   = $publicKey.Trim()
    } | ConvertTo-Json

    Invoke-WebRequest `
        -Method POST `
        -Uri $config.Git.KeysUrl `
        -Headers $headers `
        -Body $body `
        -ContentType "application/json" `
        -UseBasicParsing

    Start-Sleep -Seconds 2

    ssh-add $keyFile
    ssh-add -l

    Write-Host "Verifying ssh connection ..."

    ssh -T git@github.com
}

function Set-Git {
    $config = Get-Config
    $keyFile = Join-Path $HOME ".ssh\id_ed25519"

    # Configure git, credentials and clone repos

    Write-Host "Creating source directory ..."

    Push-Location $HOME

    if (-not (Test-Path -Path $config.Git.SourceDir -PathType Container)) {
        New-Item -ItemType Directory -Path $config.Git.SourceDir -Force
    }

    Set-Location $config.Git.SourceDir

    Write-Host "Configuring git ..."

    git config --global user.name $config.Git.UserName
    git config --global user.email $config.Git.Email
    git config --global gpg.format ssh
    git config --global user.signingkey "$keyFile.pub"
    git config --global commit.gpgsign true

    Write-Host "Cloning repositories ..."

    $headers = Get-GithubHeaders
    $response = Invoke-RestMethod `
        -Uri $config.Git.ReposUrl `
        -Headers $headers `
        -Method Get `
        -UseBasicParsing

    foreach ($repo in $response) {
        git clone $repo.ssh_url
    }

    Pop-Location

    Write-Host "Repositories cloned successfully. Source directory: ~\$($config.Git.SourceDir)"
}

function Initialize-Git {
    Install-GithubKeys
    Set-Git
}
