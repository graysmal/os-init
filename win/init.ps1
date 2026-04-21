# SCRIPT SETTINGS ==================================
$THEME = "rainbowdash" # rainbowdash | fluttershy | cats
$IMAGE_URL = "https://tongstonk.com/${THEME}.png"
$PS_URL = "https://tongstonk.com/${THEME}.gif"

$IMAGE_PATH = "$env:USERPROFILE\Pictures\backgrounds\wallpaper.jpg"
$PS_PATH = "$env:APPDATA\..\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\background.gif"
Write-Host "[i] $THEME theme selected."

# ADMIN CHECK ==================================
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] script must be run as administrator. relaunching..."
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}


# WALLPAPER ==================================
Write-Host "[i] downloading wallpaper image from URL..."
New-Item -ItemType Directory -Force -Path (Split-Path $IMAGE_PATH) | Out-Null
Invoke-WebRequest -Uri $IMAGE_URL -OutFile $IMAGE_PATH

if (Test-Path $IMAGE_PATH) {
    Write-Host "[i] wallpaper exists at $IMAGE_PATH."
    Write-Host "[i] applying wallpaper..."
    Add-Type -TypeDefinition @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    [Wallpaper]::SystemParametersInfo(20, 0, $IMAGE_PATH, 0x01 -bor 0x02) | Out-Null
    Write-Host "[+] wallpaper set."
} else {
    Write-Host "[!] wallpaper does not exist at $IMAGE_PATH."
}
# lockscreen
$imgPath = "C:\Windows\Web\Screen\img104.jpg"
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

If (!(Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
Set-ItemProperty -Path $RegPath -Name "LockScreenImageStatus" -Value 1 -Type DWord
Set-ItemProperty -Path $RegPath -Name "LockScreenImagePath"   -Value $imgPath -Type String
Set-ItemProperty -Path $RegPath -Name "LockScreenImageUrl"    -Value $imgPath -Type String

# THEMING ==================================
Write-Host "[i] applying theme settings..."
$personalizePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"

switch ($THEME) {
    "rainbowdash" { 
Write-Host "[+] theme set to rainbowdash (blue accent, dark mode)." 
Set-ItemProperty -Path $personalizePath -Name "AppsUseLightTheme"    -Value 1 -Type DWord
Set-ItemProperty -Path $personalizePath -Name "SystemUsesLightTheme" -Value 1 -Type DWord
Set-ItemProperty -Path $personalizePath -Name "ColorPrevalence" -Value 0 -Type DWord
}
    "fluttershy"  { 
Write-Host "[+] theme set to fluttershy (pink accent, dark mode)." 
Set-ItemProperty -Path $personalizePath -Name "AppsUseLightTheme"    -Value 1 -Type DWord
Set-ItemProperty -Path $personalizePath -Name "SystemUsesLightTheme" -Value 1 -Type DWord
Set-ItemProperty -Path $personalizePath -Name "ColorPrevalence" -Value 0 -Type DWord
}
    "cats"        { 
Write-Host "[+] theme set to cats (green accent, dark mode)."
Set-ItemProperty -Path $personalizePath -Name "AppsUseLightTheme"    -Value 0 -Type DWord
Set-ItemProperty -Path $personalizePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord 
Set-ItemProperty -Path $personalizePath -Name "ColorPrevalence" -Value 1 -Type DWord
}
    default       { Write-Host "[!] $THEME not found as a theme, try rainbowdash, fluttershy, or cats." }
}

# WinUtils
$winutilPath = Join-Path $PSScriptRoot "winutil-conf.ps1"
& powershell -NoProfile -File $winutilPath

# installing external apps ==================================

# CONFIGURING APPS AND KEYS ==================================
# vim --------------------------------
$vimPath = "C:\Program Files\Vim\vim92"
[Environment]::SetEnvironmentVariable(
    "Path",
    $env:Path + ";$vimPath",
    [EnvironmentVariableTarget]::User
)
# file explorer --------------------------------
(New-Object -ComObject Shell.Application).Namespace("$HOME").Self.InvokeVerb("pintohome")
# TASKBAR PINS ==================================
Write-Host "[i] pinning apps to taskbar..."
$syspinPath = "$env:TEMP\syspin.exe"

Invoke-WebRequest -Uri "https://github.com/graysmal/os-init/..." # host it yourself or:
Invoke-WebRequest -Uri "https://www.stefankueng.com/files/syspin.exe" -OutFile $syspinPath

& $syspinPath "C:\Program Files\Mozilla Firefox\firefox.exe" 5386
& $syspinPath "C:\Windows\explorer.exe" 5386
# 5386 = pin to taskbar, 5387 = unpin

Remove-Item $syspinPath
Write-Host "[+] apps pinned."

# terminal --------------------------------
Invoke-WebRequest -Uri $PS_URL -OutFile $PS_PATH
$appPath = Join-Path $PSScriptRoot "AppData"
Copy-Item $appPath -Destination "$env:APPDATA\..\.." -Recurse -Force
$terminalSettingsPath = "$env:APPDATA\..\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $terminalSettingsPath) {
    $settingsJson = Get-Content -Path $terminalSettingsPath -Raw | ConvertFrom-Json

    # Update colorScheme based on $THEME
    $settingsJson.profiles.defaults.colorScheme = $THEME

    # Convert the modified settings back to JSON and overwrite the settings.json file
    $settingsJson | ConvertTo-Json -Depth 10 | Set-Content -Path $terminalSettingsPath
    Write-Host "[+] windows terminal color scheme updated to $THEME."
} else {
    Write-Host "[!] windows terminal settings file not found at $terminalSettingsPath."
}

# ssh authorized keys --------------------------------
# TODO: don't duplicate current authorized keys
Write-Host "[i] adding SSH authorized keys..."
$sshDir = "$env:USERPROFILE\.ssh"
New-Item -ItemType Directory -Force -Path $sshDir | Out-Null
$keysContent = (Invoke-WebRequest -Uri "https://github.com/graysmal.keys" -UseBasicParsing).Content
Add-Content -Path "$sshDir\authorized_keys" -Value $keysContent
Write-Host "[+] SSH keys added."

# firefox --------------------------------
# ubuntu puts this at $HOME/.config/mozilla/firefox — windows equivalent is %APPDATA%\Mozilla\Firefox
Write-Host "[i] copying firefox config to AppData..."
$firefoxDst = "$env:APPDATA\Mozilla\Firefox"
$firefoxSrc = Join-Path (Split-Path $PSScriptRoot -Parent) "apps\firefox"
New-Item -ItemType Directory -Force -Path $firefoxDst | Out-Null
Copy-Item -Recurse -Force "$firefoxSrc\*" "$firefoxDst\"
Write-Host "[+] firefox config copied."

# CLEANUP
# remove startup apps
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "*" -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\*" -Force
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\*" -Force
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Discord /f

# remove desktop icons
Remove-Item -Path "C:\Users\Public\Desktop\*" -Force
Remove-Item -Path "$env:USERPROFILE\Desktop\*.lnk" -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1; Get-Process "explorer" | Stop-Process

Write-Host "[i] automatic installs not available for ReCycle, Reason, or Davinci Resolve."
Write-Host "[i] done! a restart is recommended for all changes to take effect."
