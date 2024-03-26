#######################################################################################################################
# Elevate if needed
#######################################################################################################################
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
	Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
	Start-Sleep 1
	Write-Host "                                               3"
	Start-Sleep 1
	Write-Host "                                               2"
	Start-Sleep 1
	Write-Host "                                               1"
	Start-Sleep 1
	Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
	Exit
}



#######################################################################################################################
# No errors throughout
#######################################################################################################################
$ErrorActionPreference = 'SilentlyContinue'



#######################################################################################################################
# Create Log Folder
#######################################################################################################################
$DebloatFolder = "C:\ProgramData\Debloat"
if (Test-Path $DebloatFolder)
{
	Write-Output "$DebloatFolder exists. Skipping."
}
else
{
	Write-Output "The folder '$DebloatFolder' doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
	Start-Sleep 1
	New-Item -Path "$DebloatFolder" -ItemType Directory
	Write-Output "The folder $DebloatFolder was successfully created."
}

Start-Transcript -Path "C:\ProgramData\Debloat\Debloat.log"



#######################################################################################################################
# Get all SID's
#######################################################################################################################
$UserSIDs = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" | Select-Object -ExpandProperty PSChildName



#######################################################################################################################
# Remove AppX Packages
#######################################################################################################################
$WhitelistedApps   = '.NET|'
$WhitelistedApps  += 'Framework|'
$WhitelistedApps  += 'Microsoft.CompanyPortal|'
$WhitelistedApps  += 'Microsoft.DesktopAppInstaller|'
$WhitelistedApps  += 'Microsoft.HEIFImageExtension|'
$WhitelistedApps  += 'Microsoft.MSPaint|'
$WhitelistedApps  += 'Microsoft.ScreenSketch|'
$WhitelistedApps  += 'Microsoft.StorePurchaseApp|'
$WhitelistedApps  += 'Microsoft.VP9VideoExtensions|'
$WhitelistedApps  += 'Microsoft.WebMediaExtensions|'
$WhitelistedApps  += 'Microsoft.WebpImageExtension|'
$WhitelistedApps  += 'Microsoft.Windows.Photos|'
$WhitelistedApps  += 'Microsoft.WindowsCalculator|'
$WhitelistedApps  += 'Microsoft.WindowsCamera|'
$WhitelistedApps  += 'Microsoft.WindowsNotepad|'
$WhitelistedApps  += 'Microsoft.WindowsStore'

$NonRemovableApps  = '1527c705-839a-4832-9118-54d4Bd6a0c89|'
$NonRemovableApps += 'c5e2524a-ea46-4f67-841f-6a9465d9d515|'
$NonRemovableApps += 'E2A4F912-2574-4A75-9BB0-0D023378592B|'
$NonRemovableApps += 'F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE|'
$NonRemovableApps += 'InputApp|'
$NonRemovableApps += 'Microsoft.AAD.BrokerPlugin|'
$NonRemovableApps += 'Microsoft.AccountsControl|'
$NonRemovableApps += 'Microsoft.BioEnrollment|'
$NonRemovableApps += 'Microsoft.CredDialogHost|'
$NonRemovableApps += 'Microsoft.ECApp|'
$NonRemovableApps += 'Microsoft.LockApp|'
$NonRemovableApps += 'Microsoft.MicrosoftEdge|'
$NonRemovableApps += 'Microsoft.MicrosoftEdgeDevToolsClient|'
$NonRemovableApps += 'Microsoft.PPIProjection|'
$NonRemovableApps += 'Microsoft.Services.Store.Engagement|'
$NonRemovableApps += 'Microsoft.UI.Xaml.2.0|'
$NonRemovableApps += 'Microsoft.VCLibs.140.00|'
$NonRemovableApps += 'Microsoft.Win32WebViewHost|'
$NonRemovableApps += 'Microsoft.Windows.Apprep.ChxApp|'
$NonRemovableApps += 'Microsoft.Windows.AssignedAccessLockApp|'
$NonRemovableApps += 'Microsoft.Windows.CapturePicker|'
$NonRemovableApps += 'Microsoft.Windows.CloudExperienceHost|'
$NonRemovableApps += 'Microsoft.Windows.ContentDeliveryManager|'
$NonRemovableApps += 'Microsoft.Windows.Cortana|'
$NonRemovableApps += 'Microsoft.Windows.NarratorQuickStart|'
#$NonRemovableApps += 'Microsoft.Windows.ParentalControls|'
$NonRemovableApps += 'Microsoft.Windows.PeopleExperienceHost|'
$NonRemovableApps += 'Microsoft.Windows.PinningConfirmationDialog|'
$NonRemovableApps += 'Microsoft.Windows.SecHealthUI|'
$NonRemovableApps += 'Microsoft.Windows.SecureAssessmentBrowser|'
$NonRemovableApps += 'Microsoft.Windows.ShellExperienceHost|'
$NonRemovableApps += 'Microsoft.Windows.XGpuEjectDialog|'
#$NonRemovableApps += 'Microsoft.XboxGameCallableUI|'
$NonRemovableApps += 'Windows.CBSPreview|'
$NonRemovableApps += 'Windows.PrintDialog|'
$NonRemovableApps += 'windows.immersivecontrolpanel|'
$NonRemovableApps += '*Nvidia*'


Get-AppxPackage -AllUsers | Where-Object {$_.Name -NotMatch $WhitelistedApps -and $_.Name -NotMatch $NonRemovableApps} | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers | Where-Object {$_.Name -NotMatch $WhitelistedApps -and $_.Name -NotMatch $NonRemovableApps} | Remove-AppxPackage -AllUsers
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -NotMatch $WhitelistedApps -and $_.PackageName -NotMatch $NonRemovableApps} | Remove-AppxProvisionedPackage -Online


$Bloatware = @(
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
	"*getstarted*"
	#"*Microsoft.Advertising.Xaml_10.1712.5.0_x64__8wekyb3d8bbwe*"
	#"*Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe*"
	"*Microsoft.BingWeather*"
	#"*Microsoft.MSPaint*"
	#"*Microsoft.MicrosoftStickyNotes*"
	#"*Microsoft.Windows.Photos*"
	#"*Microsoft.WindowsCalculator*"
	#"*Microsoft.WindowsStore*"
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
	"Microsoft.MicrosoftStickyNotes"
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
	#"Microsoft.Todos"
	"Microsoft.Whiteboard"
	"Microsoft.Windows.DevHome"
	"Microsoft.Windows.ParentalControls"
	"Microsoft.WindowsAlarms"
	"Microsoft.WindowsCamera"
	"Microsoft.WindowsFeedbackHub"
	"Microsoft.WindowsMaps"
	"Microsoft.WindowsSoundRecorder"
	"Microsoft.Xbox.TCUI"
	"Microsoft.XboxApp"
	"Microsoft.XboxGameCallableUI"
	"Microsoft.XboxGameOverlay"
	"Microsoft.XboxGamingOverlay"
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
)


foreach ($Bloat in $Bloatware)
{
	if (Get-AppxPackage -Name $Bloat -ErrorAction SilentlyContinue)
	{
		Get-AppxPackage -AllUsers -Name $Bloat | Remove-AppxPackage -AllUsers
	}
	if (Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat -ErrorAction SilentlyContinue)
	{
		Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online
	}
}



#######################################################################################################################
# Windows Chat
#######################################################################################################################
Write-Host "Windows Chat"

$Chats = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat"
if (!(Test-Path $Chats))
{
	New-Item $Chats
}
if (Test-Path $Chats)
{
	Set-ItemProperty $Chats ChatIcon -Value 3
}


$Chats = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications"
if (!(Test-Path $Chats))
{
	New-Item $Chats
}
if (Test-Path $Chats)
{
	Set-ItemProperty $Chats ConfigureChatAutoInstall -Value 0
}



#######################################################################################################################
# Windows Search
#######################################################################################################################
Write-Host "Windows Search"

$Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
if (!(Test-Path $Search))
{
	New-Item $Search
}
if (Test-Path $Search)
{
	Set-ItemProperty $Search AllowCloudSearch -Value 0
	Set-ItemProperty $Search AllowCortana -Value 0
	Set-ItemProperty $Search AllowCortanaInAAD -Value 0
	Set-ItemProperty $Search ConnectedSearchUseWeb -Value 0
	Set-ItemProperty $Search DisableWebSearch -Value 1
	Set-ItemProperty $Search SearchOnTaskbarMode -Value 0
}


$Search = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
if (!(Test-Path $Search))
{
	New-Item $Search
}
if (Test-Path $Search)
{
	Set-ItemProperty $Search BingSearchEnabled -Value 0
}


foreach ($SID in $UserSIDs)
{
	$Search = "Registry::HKU\$SID\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
	if (!(Test-Path $Search))
	{
		New-Item $Search
	}
	if (Test-Path $Search)
	{
		Set-ItemProperty $Search BingSearchEnabled -Value 0
	}
}



#######################################################################################################################
# News and Interests
#######################################################################################################################
Write-Host "News and Interests"

$NewsAndInterests = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
if (!(Test-Path $NewsAndInterests))
{
	New-Item $NewsAndInterests
}
if (Test-Path $NewsAndInterests)
{
	Set-ItemProperty $NewsAndInterests AllowNewsAndInterests -Value 0
}



#######################################################################################################################
# TaskView Button
#######################################################################################################################
Write-Host "TaskView Button"

$TaskView = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
if (!(Test-Path $TaskView))
{
	New-Item $TaskView
}
if (Test-Path $TaskView)
{
	Set-ItemProperty $TaskView HideTaskViewButton -Value 1
}



#######################################################################################################################
# Windows Feedback Experience
#######################################################################################################################
Write-Host "Windows Feedback Experience"

$Advertising = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
if (!(Test-Path $Advertising))
{
	New-Item $Advertising
}
if (Test-Path $Advertising)
{
	Set-ItemProperty $Advertising Enabled -Value 0
}

Write-Host "Windows Feedback Notifications"

$DataCollection = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (!(Test-Path $DataCollection))
{
	New-Item $DataCollection
}
if (Test-Path $DataCollection)
{
	Set-ItemProperty $DataCollection DoNotShowFeedbackNotifications -Value 1
}



#######################################################################################################################
# Bloatware (CloudContent / Content Delivery Manager)
#######################################################################################################################
Write-Host "Bloatware"

$CloudContent = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
if (!(Test-Path $CloudContent))
{
	New-Item $CloudContent
}
if (Test-Path $CloudContent)
{
	Set-ItemProperty $CloudContent DisableCloudOptimizedContent -Value 1
	Set-ItemProperty $CloudContent DisableConsumerAccountStateContent -Value 1
	Set-ItemProperty $CloudContent DisableSoftLanding -Value 1
	Set-ItemProperty $CloudContent DisableWindowsConsumerFeatures -Value 1
}


$CDM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
if (!(Test-Path $CDM))
{
	New-Item $CDM
}
if (Test-Path $CDM)
{
	Set-ItemProperty $CDM ContentDeliveryAllowed -Value 0
	Set-ItemProperty $CDM OemPreInstalledAppsEnabled -Value 0
	Set-ItemProperty $CDM PreInstalledAppsEnabled -Value 0
	Set-ItemProperty $CDM PreInstalledAppsEverEnabled -Value 0
	Set-ItemProperty $CDM SilentInstalledAppsEnabled -Value 0
	Set-ItemProperty $CDM SystemPaneSuggestionsEnabled -Value 0
}


foreach ($SID in $UserSIDs)
{
	$CDM = "Registry::HKU\$SID\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
	if (!(Test-Path $CDM))
	{
		New-Item $CDM
	}
	if (Test-Path $CDM)
	{
		Set-ItemProperty $CDM ContentDeliveryAllowed -Value 0
		Set-ItemProperty $CDM OemPreInstalledAppsEnabled -Value 0
		Set-ItemProperty $CDM PreInstalledAppsEnabled -Value 0
		Set-ItemProperty $CDM PreInstalledAppsEverEnabled -Value 0
		Set-ItemProperty $CDM SilentInstalledAppsEnabled -Value 0
		Set-ItemProperty $CDM SystemPaneSuggestionsEnabled -Value 0
	}
}



#######################################################################################################################
# Live Tiles
#######################################################################################################################
Write-Host "Live Tiles"

$LiveTiles = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
if (!(Test-Path $LiveTiles))
{
	New-Item $LiveTiles
}
if (Test-Path $LiveTiles)
{
	Set-ItemProperty $LiveTiles NoTileApplicationNotification -Value 1
}


foreach ($SID in $UserSIDs)
{
	$LiveTiles = "Registry::HKU\$SID\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
	if (!(Test-Path $LiveTiles))
	{
		New-Item $LiveTiles
	}
	if (Test-Path $LiveTiles)
	{
		Set-ItemProperty $LiveTiles NoTileApplicationNotification -Value 1
	}
}



#######################################################################################################################
# People Icon on Taskbar
#######################################################################################################################
Write-Host "People Icon"

$People = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
if (!(Test-Path $People))
{
	New-Item $People
}
if (Test-Path $People)
{
	Set-ItemProperty $People PeopleBand -Value 0
}


foreach ($SID in $UserSIDs)
{
	$People = "Registry::HKU\$SID\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
	if (!(Test-Path $People))
	{
		New-Item $People
	}
	if (Test-Path $People)
	{
		Set-ItemProperty $People PeopleBand -Value 0
	}
}



###################################################################################################
# Start Menu and Taskbar
###################################################################################################
Write-Host "Start Menu and Taskbar"
$StartMenu = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
if (!(Test-Path $StartMenu))
{
	New-Item $StartMenu
}
if (Test-Path $StartMenu)
{
	Set-ItemProperty $StartMenu HidePeopleBar -Value 1
	Set-ItemProperty $StartMenu HideRecommendedSection -Value 1
	Set-ItemProperty $StartMenu NoPinningStoreToTaskbar -Value 1
	Set-ItemProperty $StartMenu ShowOrHideMostUsedApps -Value 2
}



#######################################################################################################################
# Windows Feeds
#######################################################################################################################
Write-Host "Windows Feeds"

$Feeds = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"
if (!(Test-Path $Feeds))
{
	New-Item $Feeds
}
if (Test-Path $Feeds)
{
	Set-ItemProperty $Feeds EnableFeeds -Value 0
}



###################################################################################################
# Windows Copilot
###################################################################################################
Write-Host "Windows Copilot"
$Copilot = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
if (!(Test-Path $Copilot))
{
	New-Item $Copilot
}
if (Test-Path $Copilot)
{
	Set-ItemProperty $Copilot TurnOffWindowsCopilot -Value 1
}



###################################################################################################
# Taskleistenausrichtung
###################################################################################################
Write-Host "Windows Feeds"
$Taskbar = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
if (!(Test-Path $Taskbar))
{
	New-Item $Taskbar
}
if (Test-Path $Taskbar)
{
	Set-ItemProperty $Taskbar TaskbarAl -Value 0
}

foreach ($SID in $UserSIDs)
{
	$Taskbar = "Registry::HKU\$SID\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
	if (!(Test-Path $Taskbar))
	{
		New-Item $Taskbar
	}
	if (Test-Path $Taskbar)
	{
		Set-ItemProperty $Taskbar TaskbarAl -Value 0
	}
}



###################################################################################################
# Classic ContextMenu
###################################################################################################
Write-Host "Classic ContextMenu"
$ContextMenu = "HKCU:\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
if (!(Test-Path $ContextMenu))
{
	New-Item $ContextMenu
}
if (Test-Path $ContextMenu)
{
	New-ItemProperty -LiteralPath $ContextMenu -Name "(default)" -Value "" -PropertyType "String"
}

foreach ($SID in $UserSIDs)
{
	$ContextMenu = "Registry::HKU\$SID\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
	if (!(Test-Path $ContextMenu))
	{
		New-Item $ContextMenu
	}
	if (Test-Path $ContextMenu)
	{
		New-ItemProperty -LiteralPath $ContextMenu -Name '(default)' -Value '' -PropertyType 'String'
	}
}



###################################################################################################
# Installation von zusätzlichen Sprachoptionen verhindern
###################################################################################################
Write-Host "Windows Feeds"
$LangPacks = "HKLM:\SOFTWARE\Policies\Microsoft\Control Panel\International"
if (!(Test-Path $LangPacks))
{
	New-Item $LangPacks
}
if (Test-Path $LangPacks)
{
	Set-ItemProperty $LangPacks RestrictLanguagePacksAndFeaturesInstall -Value 1
}



###################################################################################################
# HKCR -> Extensions
###################################################################################################
Write-Host "HKCR -> Extensions"
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

foreach ($Key in $Keys)
{
	Remove-Item $Key -Recurse
}



###################################################################################################
# RENAME COMPUTER
###################################################################################################
$SerialNumber = (Get-WmiObject -Class Win32_Bios).SerialNumber
if ($env:COMPUTERNAME -ne "XXX-$SerialNumber"))
{
	Rename-Computer -NewName "XXX-$SerialNumber" -Force
}



###################################################################################################
# SCRIPT END
###################################################################################################
Write-Host "Completed"

Stop-Transcript
Exit 0