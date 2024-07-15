@echo off
cd /d "%~dp0"

REM Elevate the script using PowerShell
PowerShell.exe -Command "Start-Process -FilePath '%0' -Verb RunAs -ArgumentList '-elevated'" -NoProfile -ExecutionPolicy Bypass
exit /b

REM Run PowerShell commands with elevated privileges
PowerShell.exe -ExecutionPolicy Bypass -Command "Install-PackageProvider -Name NuGet -Force"
PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name PowerShellGet -SkipPublisherCheck -Force"
PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name HPCMSL -AcceptLicense -Force; ^
mkdir C:\SWSetup; ^
cd C:\SWSetup; ^
Install-HPImageAssistant -Extract -DestinationPath 'C:\HPIA'; ^
Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList '/Operation:Analyze /Category:All /Selection:All /Action:Install /SoftpaqDownloadFolder:C:\SWSetup /noninteractive /ReportFolder:C:\Logs -NoNewWindow -Wait; ^
New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Value HPIA -Force"
rd /s /q C:\HPIA C:\SWSetup
exit

