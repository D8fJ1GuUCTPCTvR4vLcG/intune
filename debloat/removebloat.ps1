<#
.SYNOPSIS
.Removes bloat from a fresh Windows build
.DESCRIPTION
.Removes AppX Packages
.Disables Cortana
.Removes McAfee
.Removes HP Bloat
.Removes Dell Bloat
.Removes Lenovo Bloat
.Windows 10 and Windows 11 Compatible
.Removes any unwanted installed applications
.Removes unwanted services and tasks
.Removes Edge Surf Game

.INPUTS
.OUTPUTS
C:\ProgramData\Debloat\Debloat.log
.NOTES
  Version:        4.2.6
  Author:         Andrew Taylor
  Twitter:        @AndrewTaylor_2
  WWW:            andrewstaylor.com
  Creation Date:  08/03/2022
  Purpose/Change: Initial script development
  Change 12/08/2022 - Added additional HP applications
  Change 23/09/2022 - Added Clipchamp (new in W11 22H2)
  Change 28/10/2022 - Fixed issue with Dell apps
  Change 23/11/2022 - Added Teams Machine wide to exceptions
  Change 27/11/2022 - Added Dell apps
  Change 07/12/2022 - Whitelisted Dell Audio and Firmware
  Change 19/12/2022 - Added Windows 11 start menu support
  Change 20/12/2022 - Removed Gaming Menu from Settings
  Change 18/01/2023 - Fixed Scheduled task error and cleared up $null posistioning
  Change 22/01/2023 - Re-enabled Telemetry for Endpoint Analytics
  Change 30/01/2023 - Added Microsoft Family to removal list
  Change 31/01/2023 - Fixed Dell loop
  Change 08/02/2023 - Fixed HP apps (thanks to http://gerryhampsoncm.blogspot.com/2023/02/remove-pre-installed-hp-software-during.html?m=1)
  Change 08/02/2023 - Removed reg keys for Teams Chat
  Change 14/02/2023 - Added HP Sure Apps
  Change 07/03/2023 - Enabled Location tracking (with commenting to disable)
  Change 08/03/2023 - Teams chat fix
  Change 10/03/2023 - Dell array fix
  Change 19/04/2023 - Added loop through all users for HKCU keys for post-OOBE deployments
  Change 29/04/2023 - Removes News Feed
  Change 26/05/2023 - Added Set-Acl
  Change 26/05/2023 - Added multi-language support for Set-Acl commands
  Change 30/05/2023 - Logic to check if gamepresencewriter exists before running Set-Acl to stop errors on re-run
  Change 25/07/2023 - Added Lenovo apps (Thanks to Simon Lilly and Philip Jorgensen)
  Change 31/07/2023 - Added LenovoAssist
  Change 21/09/2023 - Remove Windows backup for Win10
  Change 28/09/2023 - Enabled Diagnostic Tracking for Endpoint Analytics
  Change 02/10/2023 - Lenovo Fix
  Change 06/10/2023 - Teams chat fix
  Change 09/10/2023 - Dell Command Update change
  Change 11/10/2023 - Grab all uninstall strings and use native uninstaller instead of uninstall-package
  Change 14/10/2023 - Updated HP Audio package name
  Change 31/10/2023 - Added PowerAutomateDesktop and update Microsoft.Todos
  Change 01/11/2023 - Added fix for Windows backup removing Shell Components
  Change 06/11/2023 - Removes Windows CoPilot
  Change 07/11/2023 - HKU fix
  Change 13/11/2023 - Added CoPilot removal to .Default Users
  Change 14/11/2023 - Added logic to stop errors on HP machines without HP docs installed
  Change 14/11/2023 - Added logic to stop errors on Lenovo machines without some installers
  Change 15/11/2023 - Code Signed for additional security
  Change 02/12/2023 - Added extra logic before app uninstall to check if a user has logged in
  Change 04/01/2024 - Added Dropbox and DevHome to AppX removal
  Change 05/01/2024 - Added MSTSC to whitelist
  Change 25/01/2024 - Added logic for LenovoNow/LenovoWelcome
  Change 25/01/2024 - Updated Dell app list (thanks Hrvoje in comments)
  Change 29/01/2024 - Changed /I to /X in Dell command
  Change 30/01/2024 - Fix Lenovo Vantage version
  Change 31/01/2024 - McAfee fix and Dell changes
  Change 01/02/2024 - Dell fix
  Change 01/02/2024 - Added logic around appxremoval to stop failures in logging
  Change 05/02/2024 - Added whitelist parameters
  Change 16/02/2024 - Added wildcard to dropbox
  Change 23/02/2024 - Added Lenovo SmartMeetings
  Change 06/03/2024 - Added Lenovo View and Vantage
  Change 08/03/2024 - Added Lenovo Smart Noise Cancellation
  Change 13/03/2024 - Added updated McAfee
N/A

https://github.com/andrew-s-taylor/public/tree/main/De-Bloat
#>

############################################################################################################
#                                         Initial Setup                                                    #
#                                                                                                          #
############################################################################################################
param (
	[string[]]$customwhitelist
)

##Elevate if needed

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
	Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
	Start-Sleep 1
	Write-Host "                                               3"
	Start-Sleep 1
	Write-Host "                                               2"
	Start-Sleep 1
	Write-Host "                                               1"
	Start-Sleep 1
	Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`" -WhitelistApps {1}" -f $PSCommandPath, ($WhitelistApps -join ',')) -Verb RunAs
	Exit
}

#no errors throughout
$ErrorActionPreference = 'silentlycontinue'


#Create Folder
$DebloatFolder = "C:\ProgramData\Debloat"
If (Test-Path $DebloatFolder) {
	Write-Output "$DebloatFolder exists. Skipping."
}
Else {
	Write-Output "The folder '$DebloatFolder' doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
	Start-Sleep 1
	New-Item -Path "$DebloatFolder" -ItemType Directory
	Write-Output "The folder $DebloatFolder was successfully created."
}

Start-Transcript -Path "C:\ProgramData\Debloat\Debloat.log"

$locale = Get-WinSystemLocale | Select-Object -expandproperty Name

##Switch on locale to set variables
## Switch on locale to set variables
switch ($locale) {
	"ar-SA" {
		$everyone = "الجميع"
		$builtin = "مدمج"
	}
	"bg-BG" {
		$everyone = "Всички"
		$builtin = "Вграден"
	}
	"cs-CZ" {
		$everyone = "Všichni"
		$builtin = "Vestavěný"
	}
	"da-DK" {
		$everyone = "Alle"
		$builtin = "Indbygget"
	}
	"de-DE" {
		$everyone = "Jeder"
		$builtin = "Integriert"
	}
	"el-GR" {
		$everyone = "Όλοι"
		$builtin = "Ενσωματωμένο"
	}
	"en-US" {
		$everyone = "Everyone"
		$builtin = "Builtin"
	}    
	"en-GB" {
		$everyone = "Everyone"
		$builtin = "Builtin"
	}
	"es-ES" {
		$everyone = "Todos"
		$builtin = "Incorporado"
	}
	"et-EE" {
		$everyone = "Kõik"
		$builtin = "Sisseehitatud"
	}
	"fi-FI" {
		$everyone = "Kaikki"
		$builtin = "Sisäänrakennettu"
	}
	"fr-FR" {
		$everyone = "Tout le monde"
		$builtin = "Intégré"
	}
	"he-IL" {
		$everyone = "כולם"
		$builtin = "מובנה"
	}
	"hr-HR" {
		$everyone = "Svi"
		$builtin = "Ugrađeni"
	}
	"hu-HU" {
		$everyone = "Mindenki"
		$builtin = "Beépített"
	}
	"it-IT" {
		$everyone = "Tutti"
		$builtin = "Incorporato"
	}
	"ja-JP" {
		$everyone = "すべてのユーザー"
		$builtin = "ビルトイン"
	}
	"ko-KR" {
		$everyone = "모든 사용자"
		$builtin = "기본 제공"
	}
	"lt-LT" {
		$everyone = "Visi"
		$builtin = "Įmontuotas"
	}
	"lv-LV" {
		$everyone = "Visi"
		$builtin = "Iebūvēts"
	}
	"nb-NO" {
		$everyone = "Alle"
		$builtin = "Innebygd"
	}
	"nl-NL" {
		$everyone = "Iedereen"
		$builtin = "Ingebouwd"
	}
	"pl-PL" {
		$everyone = "Wszyscy"
		$builtin = "Wbudowany"
	}
	"pt-BR" {
		$everyone = "Todos"
		$builtin = "Integrado"
	}
	"pt-PT" {
		$everyone = "Todos"
		$builtin = "Incorporado"
	}
	"ro-RO" {
		$everyone = "Toată lumea"
		$builtin = "Incorporat"
	}
	"ru-RU" {
		$everyone = "Все пользователи"
		$builtin = "Встроенный"
	}
	"sk-SK" {
		$everyone = "Všetci"
		$builtin = "Vstavaný"
	}
	"sl-SI" {
		$everyone = "Vsi"
		$builtin = "Vgrajen"
	}
	"sr-Latn-RS" {
		$everyone = "Svi"
		$builtin = "Ugrađeni"
	}
	"sv-SE" {
		$everyone = "Alla"
		$builtin = "Inbyggd"
	}
	"th-TH" {
		$everyone = "ทุกคน"
		$builtin = "ภายในเครื่อง"
	}
	"tr-TR" {
		$everyone = "Herkes"
		$builtin = "Yerleşik"
	}
	"uk-UA" {
		$everyone = "Всі"
		$builtin = "Вбудований"
	}
	"zh-CN" {
		$everyone = "所有人"
		$builtin = "内置"
	}
	"zh-TW" {
		$everyone = "所有人"
		$builtin = "內建"
	}
	default {
		$everyone = "Everyone"
		$builtin = "Builtin"
	}
}



############################################################################################################
#                                        Remove AppX Packages                                              #
#                                                                                                          #
############################################################################################################

#Removes AppxPackages
$WhitelistedApps = 'Microsoft.WindowsNotepad|Microsoft.CompanyPortal|Microsoft.ScreenSketch|Microsoft.WindowsCalculator|Microsoft.WindowsStore|Microsoft.Windows.Photos|Microsoft.MSPaint|Microsoft.WindowsCamera|.NET|Framework|`
Microsoft.HEIFImageExtension|Microsoft.StorePurchaseApp|Microsoft.VP9VideoExtensions|Microsoft.WebMediaExtensions|Microsoft.WebpImageExtension|Microsoft.DesktopAppInstaller'
##If $customwhitelist is set, split on the comma and add to whitelist
If ($customwhitelist) {
	$customWhitelistApps = $customwhitelist -split ","
	$WhitelistedApps += "|"
	$WhitelistedApps += $customWhitelistApps -join "|"
}

#NonRemovable Apps that where getting attempted and the system would reject the uninstall, speeds up debloat and prevents 'initalizing' overlay when removing apps
$NonRemovable = '1527c705-839a-4832-9118-54d4Bd6a0c89|c5e2524a-ea46-4f67-841f-6a9465d9d515|E2A4F912-2574-4A75-9BB0-0D023378592B|F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE|InputApp|Microsoft.AAD.BrokerPlugin|Microsoft.AccountsControl|`
Microsoft.BioEnrollment|Microsoft.CredDialogHost|Microsoft.ECApp|Microsoft.LockApp|Microsoft.MicrosoftEdgeDevToolsClient|Microsoft.MicrosoftEdge|Microsoft.PPIProjection|Microsoft.Win32WebViewHost|Microsoft.Windows.Apprep.ChxApp|`
Microsoft.Windows.AssignedAccessLockApp|Microsoft.Windows.CapturePicker|Microsoft.Windows.CloudExperienceHost|Microsoft.Windows.ContentDeliveryManager|Microsoft.Windows.Cortana|Microsoft.Windows.NarratorQuickStart|`
Microsoft.Windows.ParentalControls|Microsoft.Windows.PeopleExperienceHost|Microsoft.Windows.PinningConfirmationDialog|Microsoft.Windows.SecHealthUI|Microsoft.Windows.SecureAssessmentBrowser|Microsoft.Windows.ShellExperienceHost|`
Microsoft.Windows.XGpuEjectDialog|Microsoft.XboxGameCallableUI|Windows.CBSPreview|windows.immersivecontrolpanel|Windows.PrintDialog|Microsoft.XboxGameCallableUI|Microsoft.VCLibs.140.00|Microsoft.Services.Store.Engagement|Microsoft.UI.Xaml.2.0|*Nvidia*'
Get-AppxPackage -AllUsers | Where-Object {$_.Name -NotMatch $WhitelistedApps -and $_.Name -NotMatch $NonRemovable} | Remove-AppxPackage
Get-AppxPackage -allusers | Where-Object {$_.Name -NotMatch $WhitelistedApps -and $_.Name -NotMatch $NonRemovable} | Remove-AppxPackage
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -NotMatch $WhitelistedApps -and $_.PackageName -NotMatch $NonRemovable} | Remove-AppxProvisionedPackage -Online


##Remove bloat
$Bloatware = @(
	#Unnecessary Windows 10/11 AppX Apps
	"*ActiproSoftwareLLC*"
	"*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
	"*BubbleWitch3Saga*"
	"*CandyCrush*"
	"*DevHome*"
	"*Disney*"
	"*Dolby*"
	"*Duolingo-LearnLanguagesforFree*"
	"*EclipseManager*"
	"*Facebook*"
	"*Flipboard*"
	"*Microsoft.BingWeather*"
	"*Microsoft.MicrosoftStickyNotes*"
	"*Minecraft*"
	"*Office*"
	"*PandoraMediaInc*"
	"*Royal Revolt*"
	"*Speed Test*"
	"*Spotify*"
	"*Sway*"
	"*Twitter*"
	"*Wunderlist*"
	"*gaming*"
	"C27EB4BA.DropboxOEM*"
	"Disney.37853FC22B2CE"
	"Microsoft.549981C3F5F10"
	"Microsoft.BingNews"
	"Microsoft.GamingApp"
	"Microsoft.GetHelp"
	"Microsoft.Getstarted"
	"Microsoft.Messaging"
	"Microsoft.Microsoft3DViewer"
	"Microsoft.MicrosoftJournal"
	"Microsoft.MicrosoftOfficeHub"
	"Microsoft.MicrosoftSolitaireCollection"
	"Microsoft.MixedReality.Portal"
	"Microsoft.NetworkSpeedTest"
	"Microsoft.News"
	"Microsoft.Office.Lens"
	"Microsoft.Office.OneNote"
	"Microsoft.Office.Sway"
	"Microsoft.Office.Todo.List"
	"Microsoft.OneConnect"
	"Microsoft.OutlookForWindows"
	"Microsoft.People"
	"Microsoft.PowerAutomateDesktop"
	"Microsoft.Print3D"
	"Microsoft.RemoteDesktop"
	"Microsoft.SkypeApp"
	"Microsoft.StorePurchaseApp"
	"Microsoft.Whiteboard"
	"Microsoft.Windows.DevHome"
	"Microsoft.WindowsAlarms"
	"Microsoft.WindowsFeedbackHub"
	"Microsoft.WindowsMaps"
	"Microsoft.WindowsSoundRecorder"
	"Microsoft.Xbox.TCUI"
	"Microsoft.XboxApp"
	"Microsoft.XboxGameOverlay"
	"Microsoft.XboxGamingOverlay_5.721.10202.0_neutral_~_8wekyb3d8bbwe"
	"Microsoft.XboxIdentityProvider"
	"Microsoft.XboxSpeechToTextOverlay"
	"Microsoft.YourPhone"
	"Microsoft.ZuneMusic"
	"Microsoft.ZuneVideo"
	"MicrosoftCorporationII.MicrosoftFamily"
	"MicrosoftCorporationII.QuickAssist"
	"MicrosoftTeams"
	"SpotifyAB.SpotifyMusic"
	"clipchamp.clipchamp"
	"microsoft.windowscommunicationsapps"
	#Optional: Typically not removed but you can if you need to for some reason
	#"*Microsoft.Advertising.Xaml_10.1712.5.0_x64__8wekyb3d8bbwe*"
	#"*Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe*"
	#"*Microsoft.MSPaint*"
	#"Microsoft.Todos"
	#"Microsoft.WindowsCamera"
	#"*Microsoft.Windows.Photos*"
	#"*Microsoft.WindowsCalculator*"
	#"*Microsoft.WindowsStore*"
	#"Microsoft.MicrosoftStickyNotes"
)
##If custom whitelist specified, remove from array
If ($customwhitelist) {
	$customWhitelistApps = $customwhitelist -split ","
	$Bloatware = $Bloatware | Where-Object { $customWhitelistApps -notcontains $_ }
}


foreach ($Bloat in $Bloatware) {
	If (Get-AppxPackage -Name $Bloat -ErrorAction SilentlyContinue) {
		Get-AppxPackage -allusers -Name $Bloat | Remove-AppxPackage -AllUsers
		Write-Host "Removed $Bloat."
	} Else {
		Write-Host "$Bloat not found."
	}

	If (Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat -ErrorAction SilentlyContinue) {
		Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online
		Write-Host "Removed provisioned package for $Bloat."
	} Else {
		Write-Host "Provisioned package for $Bloat not found."
	}
}



############################################################################################################
#                                        Remove Registry Keys                                              #
#                                                                                                          #
############################################################################################################

##We need to grab all SIDs to remove at user level
$UserSIDs = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" | Select-Object -ExpandProperty PSChildName


#These are the registry keys that it will delete.
		
$Keys = @(
	#Remove Background Tasks
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

	#Windows File
	"HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"

	#Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

	#Scheduled Tasks to delete
	"HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"

	#Windows Protocol Keys
	"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
	"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
	   
	#Windows Share Target
	"HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
)

#This writes the output of each key it is removing and also removes the keys listed above.
ForEach ($Key in $Keys) {
	Write-Host "Removing $Key from registry"
	Remove-Item $Key -Recurse
}


#Remove Recommended section from Start Menu
Write-Host "Remove Recommended section from Start Menu"
$Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
If (!(Test-Path $Search)) {
	New-Item $Search
}
If (Test-Path $Search) {
	Set-ItemProperty $Search HideRecommendedSection -Value 1
}


#Default empty Start Menu Layout
#Write-Host "Empty default start menu (start2.bin)"
#Invoke-WebRequest -uri "https://github.com/D8fJ1GuUCTPCTvR4vLcG/intune/raw/main/debloat/start2.bin" -outfile "C:\Windows\Temp\start2.bin"
#$startmenuTemplate = "C:\Windows\Temp\start2.bin"
#$defaultProfile = "C:\Users\default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
#If (!(Test-Path $defaultProfile)) {
#	New-Item $defaultProfile
#}
#Copy-Item -Path $startmenuTemplate -Destination $defaultProfile -Force
#Remove-Item $startmenuTemplate -Recurse



#Disables Windows Feedback Experience
Write-Host "Disabling Windows Feedback Experience program"
$Advertising = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
If (!(Test-Path $Advertising)) {
	New-Item $Advertising
}
If (Test-Path $Advertising) {
	Set-ItemProperty $Advertising Enabled -Value 0 
}


#Stops Cortana from being used as part of your Windows Search Function
Write-Host "Stopping Cortana from being used as part of your Windows Search Function"
$Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
If (!(Test-Path $Search)) {
	New-Item $Search
}
If (Test-Path $Search) {
	Set-ItemProperty $Search AllowCortana -Value 0
}


#Disables Web Search in Start Menu
Write-Host "Disabling Bing Search in Start Menu"
$WebSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
If (!(Test-Path $WebSearch)) {
	New-Item $WebSearch
}
Set-ItemProperty $WebSearch DisableWebSearch -Value 1
##Loop through all user SIDs in the registry and disable Bing Search
foreach ($sid in $UserSIDs) {
	$WebSearch = "Registry::HKU\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
	If (!(Test-Path $WebSearch)) {
		New-Item $WebSearch
	}
	Set-ItemProperty $WebSearch BingSearchEnabled -Value 0
}

Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" BingSearchEnabled -Value 0


#Stops the Windows Feedback Experience from sending anonymous data
Write-Host "Stopping the Windows Feedback Experience program"
$Period = "HKCU:\Software\Microsoft\Siuf\Rules"
If (!(Test-Path $Period)) { 
	New-Item $Period
}
Set-ItemProperty $Period PeriodInNanoSeconds -Value 0

##Loop and do the same
foreach ($sid in $UserSIDs) {
	$Period = "Registry::HKU\$sid\Software\Microsoft\Siuf\Rules"
	If (!(Test-Path $Period)) { 
		New-Item $Period
	}
	Set-ItemProperty $Period PeriodInNanoSeconds -Value 0
}

#Prevents bloatware applications from returning and removes Start Menu suggestions
Write-Host "Adding Registry key to prevent bloatware apps from returning"
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
If (!(Test-Path $registryPath)) {
	New-Item $registryPath
}
Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1 

If (!(Test-Path $registryOEM)) {
	New-Item $registryOEM
}
Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0 
Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0 
Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0 
Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0 
Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0 
Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0  

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
	$registryOEM = "Registry::HKU\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
	If (!(Test-Path $registryOEM)) {
		New-Item $registryOEM
	}
	Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0
	Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0
	Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0
	Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0
	Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0
	Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0
}

#Preping mixed Reality Portal for removal    
Write-Host "Setting Mixed Reality Portal value to 0 so that you can uninstall it in Settings"
$Holo = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"    
If (Test-Path $Holo) {
	Set-ItemProperty $Holo  FirstRunSucceeded -Value 0 
}

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
	$Holo = "Registry::HKU\$sid\Software\Microsoft\Windows\CurrentVersion\Holographic"    
	If (Test-Path $Holo) {
		Set-ItemProperty $Holo  FirstRunSucceeded -Value 0 
	}
}

#Disables Wi-fi Sense
Write-Host "Disabling Wi-Fi Sense"
$WifiSense1 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting"
$WifiSense2 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots"
$WifiSense3 = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
If (!(Test-Path $WifiSense1)) {
	New-Item $WifiSense1
}
Set-ItemProperty $WifiSense1  Value -Value 0 
If (!(Test-Path $WifiSense2)) {
	New-Item $WifiSense2
}
Set-ItemProperty $WifiSense2  Value -Value 0 
Set-ItemProperty $WifiSense3  AutoConnectAllowedOEM -Value 0 

#Disables live tiles
Write-Host "Disabling live tiles"
$Live = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"    
If (!(Test-Path $Live)) {      
	New-Item $Live
}
Set-ItemProperty $Live  NoTileApplicationNotification -Value 1 

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
	$Live = "Registry::HKU\$sid\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"    
	If (!(Test-Path $Live)) {      
		New-Item $Live
	}
	Set-ItemProperty $Live  NoTileApplicationNotification -Value 1 
}

#Disables People icon on Taskbar
Write-Host "Disabling People icon on Taskbar"
$People = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
If (Test-Path $People) {
	Set-ItemProperty $People -Name PeopleBand -Value 0
}

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
	$People = "Registry::HKU\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
	If (Test-Path $People) {
		Set-ItemProperty $People -Name PeopleBand -Value 0
	}
}

Write-Host "Disabling Cortana"
$Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
$Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
$Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
If (!(Test-Path $Cortana1)) {
	New-Item $Cortana1
}
Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0 
If (!(Test-Path $Cortana2)) {
	New-Item $Cortana2
}
Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1 
Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1 
If (!(Test-Path $Cortana3)) {
	New-Item $Cortana3
}
Set-ItemProperty $Cortana3 HarvestContacts -Value 0

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
	$Cortana1 = "Registry::HKU\$sid\SOFTWARE\Microsoft\Personalization\Settings"
	$Cortana2 = "Registry::HKU\$sid\SOFTWARE\Microsoft\InputPersonalization"
	$Cortana3 = "Registry::HKU\$sid\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
	If (!(Test-Path $Cortana1)) {
		New-Item $Cortana1
	}
	Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0 
	If (!(Test-Path $Cortana2)) {
		New-Item $Cortana2
	}
	Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1 
	Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1 
	If (!(Test-Path $Cortana3)) {
		New-Item $Cortana3
	}
	Set-ItemProperty $Cortana3 HarvestContacts -Value 0
}


#Removes 3D Objects from the 'My Computer' submenu in explorer
Write-Host "Removing 3D Objects from explorer 'My Computer' submenu"
$Objects32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
$Objects64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
If (Test-Path $Objects32) {
	Remove-Item $Objects32 -Recurse 
}
If (Test-Path $Objects64) {
	Remove-Item $Objects64 -Recurse 
}


##Removes the Microsoft Feeds from displaying
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"
$Name = "EnableFeeds"
$value = "0"

If (!(Test-Path $registryPath)) {
	New-Item -Path $registryPath -Force | Out-Null
	New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
}
Else {
	New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
}

##Kill Cortana again
Get-AppxPackage - allusers Microsoft.549981C3F5F10 | Remove AppxPackage



############################################################################################################
#                                        Remove Scheduled Tasks                                            #
#                                                                                                          #
############################################################################################################

#Disables scheduled tasks that are considered unnecessary 
Write-Host "Disabling scheduled tasks"
$task1 = Get-ScheduledTask -TaskName XblGameSaveTaskLogon -ErrorAction SilentlyContinue
If ($null -ne $task1) {
	Get-ScheduledTask  XblGameSaveTaskLogon | Disable-ScheduledTask -ErrorAction SilentlyContinue
}
$task2 = Get-ScheduledTask -TaskName XblGameSaveTask -ErrorAction SilentlyContinue
If ($null -ne $task2) {
	Get-ScheduledTask  XblGameSaveTask | Disable-ScheduledTask -ErrorAction SilentlyContinue
}
$task3 = Get-ScheduledTask -TaskName Consolidator -ErrorAction SilentlyContinue
If ($null -ne $task3) {
	Get-ScheduledTask  Consolidator | Disable-ScheduledTask -ErrorAction SilentlyContinue
}
$task4 = Get-ScheduledTask -TaskName UsbCeip -ErrorAction SilentlyContinue
If ($null -ne $task4) {
	Get-ScheduledTask  UsbCeip | Disable-ScheduledTask -ErrorAction SilentlyContinue
}
$task5 = Get-ScheduledTask -TaskName DmClient -ErrorAction SilentlyContinue
If ($null -ne $task5) {
	Get-ScheduledTask  DmClient | Disable-ScheduledTask -ErrorAction SilentlyContinue
}
$task6 = Get-ScheduledTask -TaskName DmClientOnScenarioDownload -ErrorAction SilentlyContinue
If ($null -ne $task6) {
	Get-ScheduledTask  DmClientOnScenarioDownload | Disable-ScheduledTask -ErrorAction SilentlyContinue
}



############################################################################################################
#                                             Disable Services                                             #
#                                                                                                          #
############################################################################################################
	##Write-Host "Stopping and disabling Diagnostics Tracking Service"
	#Disabling the Diagnostics Tracking Service
	##Stop-Service "DiagTrack"
	##Set-Service "DiagTrack" -StartupType Disabled



############################################################################################################
#                                        Windows 11 Specific                                               #
#                                                                                                          #
############################################################################################################

#Windows 11 Customisations
Write-Host "Removing Windows 11 Customisations"

#Remove XBox Game Bar
$packages = @(
	"Microsoft.XboxGamingOverlay",
	"Microsoft.XboxGameCallableUI",
	"Microsoft.549981C3F5F10",
	"*getstarted*",
	"Microsoft.Windows.ParentalControls"
)
##If custom whitelist specified, remove from array
If ($customwhitelist) {
	$customWhitelistApps = $customwhitelist -split ","
	$packages = $packages | Where-Object { $customWhitelistApps -notcontains $_ }
}


foreach ($package in $packages) {
	$appPackage = Get-AppxPackage -allusers $package -ErrorAction SilentlyContinue
	If ($appPackage) {
		Remove-AppxPackage -Package $appPackage.PackageFullName -AllUsers
		Write-Host "Removed $package"
	}
}

#Remove Teams Chat
$MSTeams = "MicrosoftTeams"

$WinPackage = Get-AppxPackage -allusers | Where-Object {$_.Name -eq $MSTeams}
$ProvisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $WinPackage }
If ($null -ne $WinPackage) 
{
	Remove-AppxPackage  -Package $WinPackage.PackageFullName -AllUsers
} 

If ($null -ne $ProvisionedPackage) 
{
	Remove-AppxProvisionedPackage -online -Packagename $ProvisionedPackage.Packagename -AllUsers
}

##Tweak reg permissions
Invoke-WebRequest -uri "https://github.com/D8fJ1GuUCTPCTvR4vLcG/intune/raw/main/debloat/SetACL.exe" -outfile "C:\Windows\Temp\SetACL.exe"
C:\Windows\Temp\SetACL.exe -on "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -ot reg -actn setowner -ownr "n:$everyone"
C:\Windows\Temp\SetACL.exe -on "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -ot reg -actn ace -ace "n:$everyone;p:full"


##Stop it coming back
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications"
If (!(Test-Path $registryPath)) { 
	New-Item $registryPath
}
Set-ItemProperty $registryPath ConfigureChatAutoInstall -Value 0


##Unpin it
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat"
If (!(Test-Path $registryPath)) { 
	New-Item $registryPath
}
Set-ItemProperty $registryPath "ChatIcon" -Value 2
Write-Host "Removed Teams Chat"



############################################################################################################
#                                           Windows Backup App                                             #
#                                                                                                          #
############################################################################################################

$version = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption
If ($version -like "*Windows 10*") {
	Write-Host "Removing Windows Backup"
	$filepath = "C:\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\WindowsBackup\Assets"
	If (Test-Path $filepath) {
		Remove-WindowsPackage -Online -PackageName "Microsoft-Windows-UserExperience-Desktop-Package~31bf3856ad364e35~amd64~~10.0.19041.3393"

		##Add back snipping tool functionality
		Write-Host "Adding Windows Shell Components"
		DISM /Online /Add-Capability /CapabilityName:Windows.Client.ShellComponents~~~~0.0.1.0
		Write-Host "Components Added"
	}
	Write-Host "Removed"
}



############################################################################################################
#                                           Windows CoPilot                                                #
#                                                                                                          #
############################################################################################################

$version = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption
If ($version -like "*Windows 11*") {
	Write-Host "Removing Windows Copilot"
	# Define the registry key and value
	$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
	$propertyName = "TurnOffWindowsCopilot"
	$propertyValue = 1

	# Check if the registry key exists
	If (!(Test-Path $registryPath)) {
		# If the registry key doesn't exist, create it
		New-Item -Path $registryPath -Force | Out-Null
	}

	# Get the property value
	$currentValue = Get-ItemProperty -Path $registryPath -Name $propertyName -ErrorAction SilentlyContinue

	# Check if the property exists and if its value is different from the desired value
	If ($null -eq $currentValue -or $currentValue.$propertyName -ne $propertyValue) {
		# If the property doesn't exist or its value is different, set the property value
		Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue
	}


	##Grab the default user as well
	$registryPath = "HKEY_USERS\.DEFAULT\Software\Policies\Microsoft\Windows\WindowsCopilot"
	$propertyName = "TurnOffWindowsCopilot"
	$propertyValue = 1

	# Check if the registry key exists
	If (!(Test-Path $registryPath)) {
		# If the registry key doesn't exist, create it
		New-Item -Path $registryPath -Force | Out-Null
	}

	# Get the property value
	$currentValue = Get-ItemProperty -Path $registryPath -Name $propertyName -ErrorAction SilentlyContinue

	# Check if the property exists and if its value is different from the desired value
	If ($null -eq $currentValue -or $currentValue.$propertyName -ne $propertyValue) {
		# If the property doesn't exist or its value is different, set the property value
		Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue
	}


	## Taskbar
	Write-Host "Default Taskbar Settings"
	REG LOAD HKLM\Default C:\Users\Default\NTUSER.DAT
	# Removes Task View from the Taskbar
	New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value "0" -PropertyType Dword
	# Removes Widgets from the Taskbar
	New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value "0" -PropertyType Dword
	# Removes Chat from the Taskbar
	New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value "0" -PropertyType Dword
	# Default StartMenu alignment 0=Left
	New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value "0" -PropertyType Dword
	# Removes search from the Taskbar
	reg.exe add "HKLM\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f
	REG UNLOAD HKLM\Default


	##Load the default hive from c:\users\Default\NTUSER.dat
	reg load HKU\temphive "c:\users\default\ntuser.dat"
	$registryPath = "registry::hku\temphive\Software\Policies\Microsoft\Windows\WindowsCopilot"
	$propertyName = "TurnOffWindowsCopilot"
	$propertyValue = 1

	# Check if the registry key exists
	If (!(Test-Path $registryPath)) {
		# If the registry key doesn't exist, create it
		[Microsoft.Win32.RegistryKey]$HKUCoPilot = [Microsoft.Win32.Registry]::Users.CreateSubKey("temphive\Software\Policies\Microsoft\Windows\WindowsCopilot", [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree)
		$HKUCoPilot.SetValue("TurnOffWindowsCopilot", 0x1, [Microsoft.Win32.RegistryValueKind]::DWord)
	}


	$HKUCoPilot.Flush()
	$HKUCoPilot.Close()
	[gc]::Collect()
	[gc]::WaitForPendingFinalizers()
	reg unload HKU\temphive

	Write-Host "Removed"


	foreach ($sid in $UserSIDs) {
		$registryPath = "Registry::HKU\$sid\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
		$propertyName = "TurnOffWindowsCopilot"
		$propertyValue = 1

		# Check if the registry key exists
		If (!(Test-Path $registryPath)) {
			# If the registry key doesn't exist, create it
			New-Item -Path $registryPath -Force | Out-Null
		}

		# Get the property value
		$currentValue = Get-ItemProperty -Path $registryPath -Name $propertyName -ErrorAction SilentlyContinue

		# Check if the property exists and if its value is different from the desired value
		If ($null -eq $currentValue -or $currentValue.$propertyName -ne $propertyValue) {
			# If the property doesn't exist or its value is different, set the property value
			Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue
		}
	}
}



############################################################################################################
#                                             Clear Start Menu                                             #
#                                                                                                          #
############################################################################################################

Write-Host "Clearing Start Menu"
#Delete layout file if it already exists

##Check windows version
$version = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption
If ($version -like "*Windows 10*") {
	Write-Host "Windows 10 Detected"
	Write-Host "Removing Current Layout"
	If(Test-Path C:\Windows\StartLayout.xml)
	{
		Remove-Item C:\Windows\StartLayout.xml
	}
	Write-Host "Creating Default Layout"
	#Creates the blank layout file

	Write-Output "<LayoutModificationTemplate xmlns:defaultlayout=""http://schemas.microsoft.com/Start/2014/FullDefaultLayout"" xmlns:start=""http://schemas.microsoft.com/Start/2014/StartLayout"" Version=""1"" xmlns=""http://schemas.microsoft.com/Start/2014/LayoutModification"">" >> C:\Windows\StartLayout.xml
	Write-Output " <LayoutOptions StartTileGroupCellWidth=""6"" />" >> C:\Windows\StartLayout.xml
	Write-Output " <DefaultLayoutOverride>" >> C:\Windows\StartLayout.xml
	Write-Output " <StartLayoutCollection>" >> C:\Windows\StartLayout.xml
	Write-Output " <defaultlayout:StartLayout GroupCellWidth=""6"" />" >> C:\Windows\StartLayout.xml
	Write-Output " </StartLayoutCollection>" >> C:\Windows\StartLayout.xml
	Write-Output " </DefaultLayoutOverride>" >> C:\Windows\StartLayout.xml
	Write-Output "</LayoutModificationTemplate>" >> C:\Windows\StartLayout.xml
}

If ($version -like "*Windows 11*") {
	Write-Host "Windows 11 Detected"
	Write-Host "Removing Current Layout"
	If(Test-Path "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml")
	{
		Remove-Item "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml"
	}

$blankjson = @'
{ 
	"pinnedList": [] 
}
'@

	$blankjson | Out-File "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml" -Encoding utf8 -Force
}



############################################################################################################
#                                              Remove Xbox Gaming                                          #
#                                                                                                          #
############################################################################################################

New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\xbgm" -Name "Start" -PropertyType DWORD -Value 4 -Force
Set-Service -Name XblAuthManager -StartupType Disabled
Set-Service -Name XblGameSave -StartupType Disabled
Set-Service -Name XboxGipSvc -StartupType Disabled
Set-Service -Name XboxNetApiSvc -StartupType Disabled
$task = Get-ScheduledTask -TaskName "Microsoft\XblGameSave\XblGameSaveTask" -ErrorAction SilentlyContinue
If ($null -ne $task) {
	Set-ScheduledTask -TaskPath $task.TaskPath -Enabled $false
}

##Check if GamePresenceWriter.exe exists
If (Test-Path "$env:WinDir\System32\GameBarPresenceWriter.exe") {
	Write-Host "GamePresenceWriter.exe exists"
	C:\Windows\Temp\SetACL.exe -on  "$env:WinDir\System32\GameBarPresenceWriter.exe" -ot file -actn setowner -ownr "n:$everyone"
	C:\Windows\Temp\SetACL.exe -on  "$env:WinDir\System32\GameBarPresenceWriter.exe" -ot file -actn ace -ace "n:$everyone;p:full"

	#Take-Ownership -Path "$env:WinDir\System32\GameBarPresenceWriter.exe"
	$NewAcl = Get-Acl -Path "$env:WinDir\System32\GameBarPresenceWriter.exe"
	# Set properties
	$identity = "$builtin\Administrators"
	$fileSystemRights = "FullControl"
	$type = "Allow"
	# Create new rule
	$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
	$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
	# Apply new rule
	$NewAcl.SetAccessRule($fileSystemAccessRule)
	Set-Acl -Path "$env:WinDir\System32\GameBarPresenceWriter.exe" -AclObject $NewAcl
	Stop-Process -Name "GameBarPresenceWriter.exe" -Force
	Remove-Item "$env:WinDir\System32\GameBarPresenceWriter.exe" -Force -Confirm:$false
}
Else {
	Write-Host "GamePresenceWriter.exe does not exist"
}

New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\GameDVR" -Name "AllowgameDVR" -PropertyType DWORD -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "SettingsPageVisibility" -PropertyType String -Value "hide:gaming-gamebar;gaming-gamedvr;gaming-broadcasting;gaming-gamemode;gaming-xboxnetworking" -Force
Remove-Item C:\Windows\Temp\SetACL.exe -Recurse



############################################################################################################
#                                        Disable Edge Surf Game                                            #
#                                                                                                          #
############################################################################################################

$surf = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge"
If (!(Test-Path $surf)) {
	New-Item $surf
}
New-ItemProperty -Path $surf -Name 'AllowSurfGame' -Value 0 -PropertyType DWord




Write-Host "Completed"

Stop-Transcript
