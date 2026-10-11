
# Developer Machine Setup Automation

(!) Stoped working on this because it's probably pointless since it's not going to be used.
Only had to use it to configure a couple of devices running windows 11 pro.

Possibly useful for new developers offshore, to quickly setup their development machine when joinning an organization.

## Configure Github

1. Create a dedicated github account for Better Car People and request access to the organization and repositories corresponding to your role.

2. Go to Settings -> Developer Settings -> Personal access tokens -> Classic Tokens

3. Fill out the form. Configure repository full access and GPG and SSH key access.

4. Copy token and paste into DevMachineSetup.json file under Git.PAT and configure other options like username, github user, source directory, vpn file path, etc.

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
 ./DevMachineSetup.ps1 -apps
```

To setup ssh keys, git and clone repositories:

```powershell
 ./DevMachineSetup.ps1 -repos
```

### Update all repos, fetch all branches

```powershell
 ./UpdateAllRepos.ps1
```


### Apply stashed work

```powershell
 ./ApplyStashes.ps1
```

## Install Development tools and applications

Run a powershell console as administrator and allow script execution.

```powershell
 Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

Install applications.

```powershell
 ./DevMachineSetup.ps1 -apps
```

The process is not fully automated and might require user intervention at several points.

## 