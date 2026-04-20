# SCRIPT SETTINGS ==================================
$THEME = "cats" # rainbowdash | fluttershy | cats
$IMAGE_URL = "https://tongstonk.com/${THEME}.png"
$IMAGE_PATH = "$env:USERPROFILE\Pictures\backgrounds\wallpaper.jpg"
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

#& powershell -NoProfile -File $winutilPath
# CONFIGURING APPS AND KEYS ==================================
# file explorer --------------------------------
(New-Object -ComObject Shell.Application).Namespace("$HOME").Self.InvokeVerb("pintohome")

# terminal --------------------------------

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
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1; Get-Process "explorer" | Stop-Process


Write-Host "[i] done! a restart is recommended for all changes to take effect."