# HELPER: set a registry value, creating the key if needed
function Set-Reg {
    param($Path, $Name, $Value, $Type = "DWord")
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
}
 
# INSTALLING APPS (winget) ==================================
# winget IDs sourced directly from winutil/config/applications.json
Write-Host "[i] installing apps via winget..."
$apps = @(
    "7zip.7zip",
    "Audacity.Audacity",
    "BlenderFoundation.Blender",
    "Discord.Discord",
    "Gyan.FFmpeg",
    "Mozilla.Firefox",
    "PeterPawlowski.foobar2000",
    "Git.Git",
    "MullvadVPN.MullvadVPN",
    "OBSProject.OBSStudio",
    "Obsidian.Obsidian",
    "PrismLauncher.PrismLauncher",
    "Valve.Steam",
    "Tailscale.Tailscale",
    "yt-dlp.yt-dlp"
)
foreach ($app in $apps) {
    Write-Host "[i]   installing $app..."
    winget install --id $app --silent --accept-package-agreements --accept-source-agreements
}
Write-Host "[+] apps installed."
 
# TWEAKS ==================================
 
# Activity History - Disable (WPFTweaksActivity) --------------------------------
Write-Host "[i] disabling activity history..."
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed"    0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities"  0
Write-Host "[+] activity history disabled."
 
# Consumer Features - Disable (WPFTweaksConsumerFeatures) --------------------------------
Write-Host "[i] disabling consumer features..."
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1
Write-Host "[+] consumer features disabled."
 
# Explorer Auto Folder Discovery - Disable (WPFTweaksDisableExplorerAutoDiscovery) --------
Write-Host "[i] disabling explorer auto folder discovery..."
$bags   = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags"
$bagMRU = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU"
Remove-Item -Path $bags   -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $bagMRU -Recurse -Force -ErrorAction SilentlyContinue
$allFolders = "$bags\AllFolders\Shell"
New-Item -Path $allFolders -Force | Out-Null
New-ItemProperty -Path $allFolders -Name "FolderType" -Value "NotSpecified" -PropertyType String -Force | Out-Null
Write-Host "[+] explorer auto folder discovery disabled."
 
# WPBT - Disable (WPFTweaksWPBT) --------------------------------
Write-Host "[i] disabling WPBT..."
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "DisableWpbtExecution" 1
Write-Host "[+] WPBT disabled."
 
# Game DVR - Disable (WPFTweaksDVR) --------------------------------
Write-Host "[i] disabling game DVR..."
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" "AppCaptureEnabled" 0
Set-Reg "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 0
Write-Host "[+] game DVR disabled."
 
# Location Tracking - Disable (WPFTweaksLocation) --------------------------------
Write-Host "[i] disabling location tracking..."
Set-Service -Name "lfsvc" -StartupType Disabled -ErrorAction SilentlyContinue
Stop-Service  -Name "lfsvc" -Force -ErrorAction SilentlyContinue
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "Deny" "String"
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" "SensorPermissionState" 0
Set-Reg "HKLM:\SYSTEM\Maps" "AutoUpdateEnabled" 0
Write-Host "[+] location tracking disabled."
 
# Services - Set to Manual/Disabled (WPFTweaksServices) --------------------------------
Write-Host "[i] configuring services..."
$services = @{
    "ALG"                           = "Manual"
    "AppMgmt"                       = "Manual"
    "AppReadiness"                  = "Manual"
    "AppVClient"                    = "Disabled"
    "Appinfo"                       = "Manual"
    "AssignedAccessManagerSvc"      = "Disabled"
    "AudioEndpointBuilder"          = "Automatic"
    "AudioSrv"                      = "Automatic"
    "AxInstSV"                      = "Manual"
    "BDESVC"                        = "Manual"
    "BITS"                          = "AutomaticDelayedStart"
    "BTAGService"                   = "Manual"
    "BthAvctpSvc"                   = "Automatic"
    "CDPSvc"                        = "Manual"
    "COMSysApp"                     = "Manual"
    "CertPropSvc"                   = "Manual"
    "CryptSvc"                      = "Automatic"
    "CscService"                    = "Manual"
    "DPS"                           = "Automatic"
    "DevQueryBroker"                = "Manual"
    "DeviceAssociationService"      = "Manual"
    "DeviceInstall"                 = "Manual"
    "Dhcp"                          = "Automatic"
    "DiagTrack"                     = "Disabled"
    "DialogBlockingService"         = "Disabled"
    "DispBrokerDesktopSvc"          = "Automatic"
    "DisplayEnhancementService"     = "Manual"
    "EFS"                           = "Manual"
    "EapHost"                       = "Manual"
    "EventLog"                      = "Automatic"
    "EventSystem"                   = "Automatic"
    "FDResPub"                      = "Manual"
    "FontCache"                     = "Automatic"
    "FrameServer"                   = "Manual"
    "FrameServerMonitor"            = "Manual"
    "GraphicsPerfSvc"               = "Manual"
    "HvHost"                        = "Manual"
    "IKEEXT"                        = "Manual"
    "InstallService"                = "Manual"
    "InventorySvc"                  = "Manual"
    "IpxlatCfgSvc"                  = "Manual"
    "KeyIso"                        = "Automatic"
    "KtmRm"                         = "Manual"
    "LanmanServer"                  = "Automatic"
    "LanmanWorkstation"             = "Automatic"
    "LicenseManager"                = "Manual"
    "LxpSvc"                        = "Manual"
    "MSDTC"                         = "Manual"
    "MSiSCSI"                       = "Manual"
    "MapsBroker"                    = "AutomaticDelayedStart"
    "McpManagementService"          = "Manual"
    "MicrosoftEdgeElevationService" = "Manual"
    "NaturalAuthentication"         = "Manual"
    "NcaSvc"                        = "Manual"
    "NcbService"                    = "Manual"
    "NcdAutoSetup"                  = "Manual"
    "NetSetupSvc"                   = "Manual"
    "NetTcpPortSharing"             = "Disabled"
    "Netman"                        = "Manual"
    "NlaSvc"                        = "Manual"
    "PcaSvc"                        = "Manual"
    "PeerDistSvc"                   = "Manual"
    "PerfHost"                      = "Manual"
    "PhoneSvc"                      = "Manual"
    "PlugPlay"                      = "Manual"
    "PolicyAgent"                   = "Manual"
    "Power"                         = "Automatic"
    "PrintNotify"                   = "Manual"
    "ProfSvc"                       = "Automatic"
    "PushToInstall"                 = "Manual"
    "QWAVE"                         = "Manual"
    "RasAuto"                       = "Manual"
    "RasMan"                        = "Manual"
    "RemoteAccess"                  = "Disabled"
    "RemoteRegistry"                = "Disabled"
    "RetailDemo"                    = "Manual"
    "RmSvc"                         = "Manual"
    "RpcLocator"                    = "Manual"
    "SCPolicySvc"                   = "Manual"
    "SCardSvr"                      = "Manual"
    "SDRSVC"                        = "Manual"
    "SEMgrSvc"                      = "Manual"
    "SENS"                          = "Automatic"
    "SNMPTrap"                      = "Manual"
    "SSDPSRV"                       = "Manual"
    "SamSs"                         = "Automatic"
    "ScDeviceEnum"                  = "Manual"
    "SensorDataService"             = "Manual"
    "SensorService"                 = "Manual"
    "SensrSvc"                      = "Manual"
    "SessionEnv"                    = "Manual"
    "SharedAccess"                  = "Manual"
    "ShellHWDetection"              = "Automatic"
    "SmsRouter"                     = "Manual"
    "Spooler"                       = "Automatic"
    "SstpSvc"                       = "Manual"
    "StiSvc"                        = "Manual"
    "StorSvc"                       = "Manual"
    "SysMain"                       = "Automatic"
    "TapiSrv"                       = "Manual"
    "TermService"                   = "Manual"
    "Themes"                        = "Automatic"
    "TieringEngineService"          = "Manual"
    "TokenBroker"                   = "Manual"
    "TrkWks"                        = "Automatic"
    "TroubleshootingSvc"            = "Manual"
    "TrustedInstaller"              = "Manual"
    "UevAgentService"               = "Disabled"
    "UmRdpService"                  = "Manual"
    "UserManager"                   = "Automatic"
    "UsoSvc"                        = "Manual"
    "VSS"                           = "Manual"
    "VaultSvc"                      = "Manual"
    "W32Time"                       = "Manual"
    "WEPHOSTSVC"                    = "Manual"
    "WFDSConMgrSvc"                 = "Manual"
    "WMPNetworkSvc"                 = "Manual"
    "WManSvc"                       = "Manual"
    "WPDBusEnum"                    = "Manual"
    "WSAIFabricSvc"                 = "Manual"
    "WSearch"                       = "AutomaticDelayedStart"
    "WalletService"                 = "Manual"
    "WarpJITSvc"                    = "Manual"
    "WbioSrvc"                      = "Manual"
    "Wcmsvc"                        = "Automatic"
    "WdiServiceHost"                = "Manual"
    "WdiSystemHost"                 = "Manual"
    "WebClient"                     = "Manual"
    "Wecsvc"                        = "Manual"
    "WerSvc"                        = "Manual"
    "WiaRpc"                        = "Manual"
    "WinRM"                         = "Manual"
    "Winmgmt"                       = "Automatic"
    "WpcMonSvc"                     = "Manual"
    "WpnService"                    = "Manual"
    "XblAuthManager"                = "Manual"
    "XblGameSave"                   = "Manual"
    "XboxGipSvc"                    = "Manual"
    "XboxNetApiSvc"                 = "Manual"
    "autotimesvc"                   = "Manual"
    "bthserv"                       = "Manual"
    "camsvc"                        = "Manual"
    "cloudidsvc"                    = "Manual"
    "dcsvc"                         = "Manual"
    "defragsvc"                     = "Manual"
    "diagsvc"                       = "Manual"
    "dmwappushservice"              = "Manual"
    "dot3svc"                       = "Manual"
    "edgeupdate"                    = "Manual"
    "edgeupdatem"                   = "Manual"
    "fdPHost"                       = "Manual"
    "fhsvc"                         = "Manual"
    "hidserv"                       = "Manual"
    "icssvc"                        = "Manual"
    "iphlpsvc"                      = "Automatic"
    "lfsvc"                         = "Manual"
    "lltdsvc"                       = "Manual"
    "lmhosts"                       = "Manual"
    "netprofm"                      = "Manual"
    "nsi"                           = "Automatic"
    "perceptionsimulation"          = "Manual"
    "pla"                           = "Manual"
    "seclogon"                      = "Manual"
    "shpamsvc"                      = "Disabled"
    "smphost"                       = "Manual"
    "ssh-agent"                     = "Disabled"
    "svsvc"                         = "Manual"
    "swprv"                         = "Manual"
    "tzautoupdate"                  = "Disabled"
    "upnphost"                      = "Manual"
}
foreach ($svc in $services.GetEnumerator()) {
    # Set-Service doesn't accept AutomaticDelayedStart; pass Automatic and set the
    # DelayedAutoStart registry value separately below.
    $startType = if ($svc.Value -eq "AutomaticDelayedStart") { "Automatic" } else { $svc.Value }
    Set-Service -Name $svc.Key -StartupType $startType -ErrorAction SilentlyContinue
}
foreach ($svc in ($services.GetEnumerator() | Where-Object { $_.Value -eq "AutomaticDelayedStart" })) {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($svc.Key)"
    if (Test-Path $regPath) {
        Set-ItemProperty -Path $regPath -Name "DelayedAutoStart" -Value 1 -Type DWord -Force
    }
}
Write-Host "[+] services configured."
 
# Telemetry - Disable (WPFTweaksTelemetry) --------------------------------
Write-Host "[i] disabling telemetry..."
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"                       "Enabled"                                     0
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"                               "TailoredExperiencesWithDiagnosticDataEnabled" 0
Set-Reg "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy"                  "HasAccepted"                                 0
Set-Reg "HKCU:\Software\Microsoft\Input\TIPC"                                                   "Enabled"                                     0
Set-Reg "HKCU:\Software\Microsoft\InputPersonalization"                                         "RestrictImplicitInkCollection"               1
Set-Reg "HKCU:\Software\Microsoft\InputPersonalization"                                         "RestrictImplicitTextCollection"              1
Set-Reg "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore"                        "HarvestContacts"                             0
Set-Reg "HKCU:\Software\Microsoft\Personalization\Settings"                                     "AcceptedPrivacyPolicy"                       0
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"               "AllowTelemetry"                              0
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"                     "Start_TrackProgs"                            0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"                                      "PublishUserActivities"                       0
Set-Reg "HKCU:\Software\Microsoft\Siuf\Rules"                                                   "NumberOfSIUFInPeriod"                        0
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"                            "RealTimeIsUniversal"                         1 "QWord"
Write-Host "[+] telemetry disabled."
 
# Disk Cleanup (WPFTweaksDiskCleanup) --------------------------------
# Write-Host "[i] running disk cleanup..."
# Start-Process "cleanmgr.exe" -ArgumentList "/d C: /VERYLOWDISK" -Wait -ErrorAction SilentlyContinue
# Start-Process "Dism.exe" -ArgumentList "/online /Cleanup-Image /StartComponentCleanup /ResetBase" -Wait -ErrorAction SilentlyContinue
# Write-Host "[+] disk cleanup done."
 
# Delete Temp Files (WPFTweaksDeleteTempFiles) --------------------------------
Write-Host "[i] deleting temp files..."
Remove-Item -Path "$env:Temp\*"            -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "[+] temp files deleted."
 
# End Task on Taskbar (WPFTweaksEndTaskOnTaskbar) --------------------------------
Write-Host "[i] enabling end task on taskbar..."
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" "TaskbarEndTask" 1
Write-Host "[+] end task on taskbar enabled."
 
# PowerShell 7 Telemetry - Disable (WPFTweaksPowershell7Tele) --------------------------------
Write-Host "[i] disabling PowerShell 7 telemetry..."
[Environment]::SetEnvironmentVariable("POWERSHELL_TELEMETRY_OPTOUT", "1", "Machine")
Write-Host "[+] PowerShell 7 telemetry disabled."
 
# Store Search - Disable (WPFTweaksDisableStoreSearch) --------------------------------
Write-Host "[i] disabling Store search results in Start..."
$storeDb = "$env:LocalAppData\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalState\store.db"
if (Test-Path $storeDb) { icacls $storeDb /deny "Everyone:F" | Out-Null }
Write-Host "[+] Store search disabled."
 
# Right-Click Menu - Restore old layout (WPFTweaksRightClickMenu) --------------------------------
Write-Host "[i] restoring classic right-click menu..."
New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Name "InprocServer32" -Force -Value "" | Out-Null
Write-Host "[+] classic right-click menu restored."
 
# OneDrive - Remove (WPFTweaksRemoveOneDrive) --------------------------------
Write-Host "[i] removing OneDrive..."
icacls $env:OneDrive /deny "Administrators:(D,DC)" 2>$null
Start-Process "C:\Windows\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -ErrorAction SilentlyContinue
Stop-Process -Name "FileCoAuth","explorer" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LocalAppData\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\ProgramData\Microsoft OneDrive"    -Recurse -Force -ErrorAction SilentlyContinue
icacls $env:OneDrive /grant "Administrators:(D,DC)" 2>$null
Set-Service -Name "OneSyncSvc" -StartupType Disabled -ErrorAction SilentlyContinue
Write-Host "[+] OneDrive removed."
 
# Xbox & Gaming - Remove (WPFTweaksXboxRemoval) --------------------------------
Write-Host "[i] removing Xbox/gaming components..."
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" "AppCaptureEnabled" 0
foreach ($pkg in @(
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.GamingApp",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxGamingOverlay"
)) {
    Get-AppxPackage -AllUsers $pkg -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
}
Write-Host "[+] Xbox components removed."
 
# Edge - Remove (WPFTweaksRemoveEdge) --------------------------------
# winutil calls its internal Invoke-WinUtilRemoveEdge; replicated here.
Write-Host "[i] removing Microsoft Edge..."
Get-AppxPackage -AllUsers "Microsoft.MicrosoftEdge.Stable" -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
$edgeDir = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application"
if (Test-Path $edgeDir) {
    $setup = Get-ChildItem "$edgeDir\*\Installer\setup.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($setup) {
        Start-Process $setup.FullName -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait -ErrorAction SilentlyContinue
    }
}
Write-Host "[+] Edge removal attempted (may require reboot to complete)."
 
# Edge - Debloat (WPFTweaksEdgeDebloat) --------------------------------
Write-Host "[i] applying Edge debloat policies..."
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate"                     "CreateDesktopShortcutDefault"          0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "PersonalizationReportingEnabled"       0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallBlocklist" "1" "ofefcgjbeghpigppfmkologfjadafddi" "String"
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "ShowRecommendationsEnabled"            0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "HideFirstRunExperience"                1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "UserFeedbackAllowed"                   0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "ConfigureDoNotTrack"                   1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "AlternateErrorPagesEnabled"            0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "EdgeCollectionsEnabled"                0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "EdgeShoppingAssistantEnabled"          0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "MicrosoftEdgeInsiderPromotionEnabled"  0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "ShowMicrosoftRewards"                  0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "WebWidgetAllowed"                      0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "DiagnosticData"                        0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "EdgeAssetDeliveryServiceEnabled"       0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "WalletDonationEnabled"                 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                           "DefaultBrowserSettingsCampaignEnabled" 0
Write-Host "[+] Edge debloat policies applied."
 
# Explorer Gallery - Remove (WPFTweaksRemoveGallery) --------------------------------
Write-Host "[i] removing Explorer Gallery..."
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" -ErrorAction SilentlyContinue
Write-Host "[+] Explorer Gallery removed."
 
# Explorer Home - Remove, set This PC as default (WPFTweaksRemoveHome) ----------------
Write-Host "[i] removing Explorer Home..."
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" -ErrorAction SilentlyContinue
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" 1
Write-Host "[+] Explorer Home removed."
 
# Razer Auto-Install - Block (WPFTweaksRazerBlock) --------------------------------
Write-Host "[i] blocking Razer auto-install..."
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching"  "SearchOrderConfig"   0
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer" "DisableCoInstallers" 1
$razerPath = "C:\Windows\Installer\Razer"
if (Test-Path $razerPath) {
    Remove-Item "$razerPath\*" -Recurse -Force -ErrorAction SilentlyContinue
} else {
    New-Item -Path $razerPath -ItemType Directory -Force | Out-Null
}
icacls $razerPath /deny "Everyone:(W)" | Out-Null
Write-Host "[+] Razer auto-install blocked."
 
# Copilot - Remove (WPFTweaksRemoveCopilot) --------------------------------
Write-Host "[i] removing Copilot..."
Get-AppxPackage -AllUsers *Copilot* -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
Get-AppxPackage -AllUsers "Microsoft.MicrosoftOfficeHub" -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
$coreAI = (Get-AppxPackage "MicrosoftWindows.Client.CoreAI" -ErrorAction SilentlyContinue).PackageFullName
if ($coreAI) {
    $sid = (Get-LocalUser $env:UserName).Sid.Value
    New-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\$sid\$coreAI" -Force | Out-Null
    Remove-AppxPackage $coreAI -ErrorAction SilentlyContinue
}
Write-Host "[+] Copilot removed."
 
# TOGGLES ==================================
 
# Show File Extensions (WPFToggleShowExt) --------------------------------
Write-Host "[i] enabling visible file extensions..."
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0
Write-Host "[+] file extensions visible."
 
# Show Hidden Files (WPFToggleHiddenFiles) --------------------------------
Write-Host "[i] enabling hidden files..."
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1
Write-Host "[+] hidden files visible."
 
# Restart Explorer to apply toggle changes --------------------------------
Write-Host "[i] restarting Explorer..."
Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process "explorer.exe"
Write-Host "[+] Explorer restarted."