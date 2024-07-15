cmd /c PowerShell.exe -ExecutionPolicy Bypass -Command "Install-PackageProvider -Name NuGet -Force" ^
  & PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name PowerShellGet -SkipPublisherCheck -Force" ^
  & PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name HPCMSL -AcceptLicense -Force" ^
  & mkdir C:\SWSetup ^
  & cd C:\SWSetup ^
  & Install-HPImageAssistant -Extract -DestinationPath 'C:\HPIA' ^
  & Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList '/Operation:Analyze /Category:All /Selection:All /Action:Install /SoftpaqDownloadFolder:C:\SWSetup /noninteractive /ReportFolder:C:\Logs' -NoNewWindow -Wait ^
  & New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Name HPIA -Value "cmd /c rd /s /q C:\HPIA & rd /s /q C:\SWSetup" -Force ^
  & exit
