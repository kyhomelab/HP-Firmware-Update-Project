@echo off
cd /d "%~dp0"

REM Check if running as administrator
NET SESSION >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo Administrator rights confirmed. Proceeding with installation.
) ELSE (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process -Verb RunAs -FilePath '%0' -ArgumentList '-elevated'" >nul 2>&1
    exit /b
)

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
