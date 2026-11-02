
# Developer Machine Setup Automation

(!) Stoped working on this because it's probably pointless since it's not going to be used.
Only had to use it to configure a couple of devices running windows 11 pro.

Possibly useful for new developers offshore, to quickly setup their development machine when joinning an organization.

## Configure Github

1. Request access to the organization and repositories corresponding to your role.

2. Go to Settings -> Developer Settings -> Personal access tokens -> Classic Tokens

3. Fill out the form. Configure repository full access and GPG and SSH key access.

4. Copy token and paste into config.json file under Git.Token and configure other options like username, github user, source directory, etc.

### Setup git, ssh keys and a local copy of the repositories

Run a powershell console as administrator and allow script execution.

```powershell
 Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
```

Confirm with:

```powershell
 Get-ExecutionPolicy -List
```

To install development tools and applications:

```powershell
 ./Setup.ps1 -apps
```

To setup ssh keys, git and clone repositories:

```powershell
 ./Setup.ps1 -repos
```

### Update all repos, fetch all branches

```powershell
 ./UpdateRepos.ps1
```


### Apply stashed work

```powershell
 ./Stash.ps1 -save|apply
```

## Install Development tools and applications

Run a powershell console as administrator and allow script execution.

```powershell
 Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

Install applications.

```powershell
 ./Setup.ps1 -apps
```

The process is not fully automated and might require user intervention at several points.

## 