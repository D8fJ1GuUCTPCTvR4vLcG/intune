# https://github.com/andrew-s-taylor/public/tree/main/De-Bloat


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

$templateFilePath = "C:\ProgramData\Debloat\removebloat.ps1"

Invoke-WebRequest `
-Uri "https://raw.githubusercontent.com/D8fJ1GuUCTPCTvR4vLcG/intune/main/debloat/removebloat.ps1" `
-OutFile $templateFilePath `
-UseBasicParsing `
-Headers @{"Cache-Control"="no-cache"}


##Populate between the speechmarks any apps you want to whitelist, comma-separated
$arguments = ' -customwhitelist ""'


Invoke-Expression -Command "$templateFilePath $arguments"