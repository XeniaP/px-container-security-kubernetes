# Define primero las variables
$username = "trendmicro"
$password = ConvertTo-SecureString "trendmicro" -AsPlainText -Force
New-LocalUser -Name $username -Password $password -FullName "trendmicro" -Description "User for trendmicro access"
Add-LocalGroupMember -Group "Administrators" -Member $username

net user Administrator "trendmicro"

Get-NetFirewallRule -DisplayGroup "Remote Desktop" | Where-Object {$_.Enabled -eq "True"}
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Instalar Google Chrome
$chromeInstaller = "$env:USERPROFILE\Downloads\chrome_installer.exe"
Invoke-WebRequest "https://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $chromeInstaller
Start-Process -FilePath $chromeInstaller -ArgumentList "/silent /install" -Wait

# Instalar Visual Studio Code
$vscodeInstaller = "$env:USERPROFILE\Downloads\vscode_installer.exe"
Invoke-WebRequest "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -OutFile $vscodeInstaller
Start-Process -FilePath $vscodeInstaller -ArgumentList "/silent" -Wait

# Instalar Git
$gitInstaller = "$env:USERPROFILE\Downloads\git_installer.exe"
Invoke-WebRequest "https://github.com/git-for-windows/git/releases/download/v2.34.1.windows.1/Git-2.34.1-64-bit.exe" -OutFile $gitInstaller
Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT" -Wait

# Configurar pestañas predeterminadas en Chrome para el Kubernetes Dashboard
$chromePrefsPath = "$env:APPDATA\Google\Chrome\User Data\Default\Preferences"
# Obtener MASTER_IP desde SSM Parameter Store
$masterIp = (Get-SSMParameterValue -Name "/k3s/cluster/master-ip").Value
# Configuración del entorno utilizando MASTER_IP
$dashboardUrl = "http://$masterIp:6443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
$chromePrefs = @{
    "session" = @{
        "restore_on_startup" = 4
        "urls_to_restore_on_startup" = @($dashboardUrl)
    }
}

$chromePrefs | ConvertTo-Json | Set-Content -Path $chromePrefsPath
