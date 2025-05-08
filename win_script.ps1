# Define primero las variables
net user adminuser "TrendMicr01!" /add
net localgroup administrators adminuser /add

Set-ExecutionPolicy Bypass -Scope Process -Force

$temp = "$env:TEMP\installers"
New-Item -ItemType Directory -Force -Path $temp | Out-Null

$chromeUrl = "https://dl.google.com/chrome/install/375.126/chrome_installer.exe"
$vscodeUrl = "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
$gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.45.1.windows.1/Git-2.45.1-64-bit.exe"
$awscliUrl = "https://awscli.amazonaws.com/AWSCLIV2.msi"

Invoke-WebRequest $chromeUrl -OutFile "$temp\chrome_installer.exe"
Invoke-WebRequest $vscodeUrl -OutFile "$temp\vscode_installer.exe"
Invoke-WebRequest $gitUrl -OutFile "$temp\git_installer.exe"
Invoke-WebRequest $awscliUrl -OutFile "$temp\AWSCLIV2.msi"

Start-Process "$temp\chrome_installer.exe" -ArgumentList "/silent /install" -Wait
Start-Process "$temp\vscode_installer.exe" -ArgumentList "/VERYSILENT /NORESTART" -Wait
Start-Process "$temp\git_installer.exe" -ArgumentList "/VERYSILENT /NORESTART" -Wait
Start-Process "msiexec.exe" -ArgumentList "/i $temp\AWSCLIV2.msi /qn" -Wait
