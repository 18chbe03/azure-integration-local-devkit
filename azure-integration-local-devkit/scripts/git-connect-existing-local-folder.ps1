param(
    [string]$RemoteUrl = "https://github.com/18chbe03/azure-integration-local-devkit.git"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

git init
git branch -M main

if ((git remote) -contains "origin") {
    git remote set-url origin $RemoteUrl
} else {
    git remote add origin $RemoteUrl
}

git add .
git commit -m "Add local Azure integration devkit starter"
git push -u origin main
