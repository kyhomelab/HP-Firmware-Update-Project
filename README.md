# HP Firmware Update Project
I'm tasked with figuring out a way to push HP driver updates to endpoint user laptops in the company.

## Summary
Need to develop a process for maintaining and deploying HP drivers to our laptop fleet. Not all drivers are released via windows update so using the driver update ring in Intune is not as ideal but could be an option to investigate. 

Also found the following blog posts that utilize HP Image assistant in conjunction with Intune to push out driver updates, this looks promising but will require research and testing. 

HP Developers Portal | Using HP Image Assistant with Microsoft Endpoint Manager

HP drivers with Intune and Proactive Remediations | scloud

## My Documentation from ClickUp
> **DISCLAIMER: Most of the documentation below is my thought process and how I went from one point to another looking for information. A lot of it probably will not make too much sense.**

In summary, the Company Portal shows Configuration Manager-deployed applications for all co-managed clients that use it, while Software Center allows users to install and manage software on their devices.
> Was trying to figure out the difference between Company Portal and Software Center

https://www.reddit.com/r/sysadmin/comments/oca5vu/sccm_hp_mik_hp_patch_assistant/

https://www.reddit.com/r/SCCM/comments/zga6x9/how_do_yall_handle_firmware_updates/

Same here for Dell but for HP we automated the HPIA for local run via command line through Scheduled task.

- HP Image Assistant
- If you need to troubleshoot an end-user issue relating to the BIOS, BIOS settings, drivers, or software, you can run HPIA on the system to compare it to the corresponding HP reference image or any other known, good image XML file.

https://ftp.hp.com/pub/caps-softpaq/cmit/whitepapers/HPIAUserGuide.pdf

https://www.hp.com/us-en/solutions/client-management-solutions.html?jumpid=va_5b67f45b1f

https://www.hp.com/us-en/solutions/client-management-solutions/download.html?jumpid=va_5b67f45b1f

https://hpia.hpcloud.hp.com/downloads/driverpackcatalog/HP_Driverpack_Matrix_x64.html?jumpid=va_5b67f45b1f

> Next steps figure out HP Image Assistant

https://support.hp.com/us-en/document/ish_7636709-7636753-16

Link for HPIA download: https://hpia.hpcloud.hp.com/downloads/hpia/hp-hpia-5.2.1.exe?jumpid=va_5b67f45b1f

> Possible cmd to run:

https://www.reddit.com/r/Hewlett_Packard/comments/r11637/hp_image_assistant_driver_maintenance/

https://www.reddit.com/r/Intune/comments/ogfuvz/hp_image_assistant_deployed_to_a_device/

https://msendpointmgr.com/2020/09/10/automatically-install-the-latest-hp-drivers-during-autopilot-provisioning/?

https://techcommunity.microsoft.com/t5/windows-it-pro-blog/introducing-a-new-deployment-service-for-driver-and-firmware/ba-p/2176942

https://www.reddit.com/r/SCCM/comments/nswjs3/how_best_to_deploy_hp_drivers_and_bios_updates/

For my HP fleet, I run HP's Client Management Script Library to run HP Image Assistant. I created an "contentless" application with the following in the installation program field (remove the bolded text if you don't have a BIOS password):

```
cmd /c PowerShell.exe -ExecutionPolicy Bypass -Command "Install-PackageProvider -Name NuGet -Force" & PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name PowerShellGet -SkipPublisherCheck -Force" & PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name HPCMSL -AcceptLicense -Force; & mkdir C:\SWSetup; & cd C:\SWSetup; & Install-HPImageAssistant -Extract -DestinationPath 'C:\HPIA'; & Set-HPBIOSSetupPassword -NewPassword '123456789'" & PowerShell.exe -ExecutionPolicy Bypass -Command "Write-HPFirmwarePasswordFile -password '2627838604' -outfile C:\SWSetup\currentbiossetuppwd.bin; & Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList '/Operation:Analyze /Category:All /Selection:All /Action:Install /SoftpaqDownloadFolder:C:\SWSetup /noninteractive /ReportFolder:C:\Logs /BIOSPwdFile:C:\SWSetup\currentbiossetuppwd.bin' -NoNewWindow -Wait; & New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Value HPIA -Force" & rd /s /q C:\HPIA C:\SWSetup & exit
```

This creates a reg key for your detection method that erases after reboot:

HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce REG_SZ HPIA

It looks crazy but this means I never have to upgrade, package and distribute HPIA every time it updates.

https://developers.hp.com/hp-client-management/doc/client-management-script-library <br>

After running script, it prompts for a restart, when able, and it is running through updates on bootup: <br>
- 7 updates <br>
- Thunderbolt <br>
- USB-C Controller Firmware <br>
- Camera Controller <br>
- Fingerprint controller <br>
- Just a few that I caught <br>

On start up its now prompting me to set up a PIN

- Gonna try shutting down and restarting to see if there is a change
- Going into BIOS I am now required to enter a password   
- The BIOS password is 123456789
- Will remove BIOS password from script
- After restarting it is still asking for Windows Hello
- Created a pin, seems to be only for login 
- Logging out to see if it requires it
- It says that the option for PIN is temp unavailable

Here is a look at a comparison between mine and a coworkers HP System Information 

<br>

![HP System](https://imgur.com/CuAwCxe.jpg)
![HP System 2](https://imgur.com/egihQfp.jpg)

<br>

```
cmd /c PowerShell.exe -ExecutionPolicy Bypass -Command "Install-PackageProvider -Name NuGet -Force" & PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name PowerShellGet -SkipPublisherCheck -Force" & PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name HPCMSL -AcceptLicense -Force; & mkdir C:\SWSetup; & cd C:\SWSetup; & Install-HPImageAssistant -Extract -DestinationPath 'C:\HPIA'; & Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList '/Operation:Analyze /Category:All /Selection:All /Action:Install /SoftpaqDownloadFolder:C:\SWSetup /noninteractive /ReportFolder:C:\Logs -NoNewWindow -Wait; & New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Value HPIA -Force" & rd /s /q C:\HPIA C:\SWSetup & exit
```
<br>

> Updated without BIOS Password

Checking HP Support Assistant (downloaded), it does not show any drivers that need to be installed or updated

![HP Support Assistant](https://imgur.com/0mZv3Ra.jpg)

<br> The CMD works successfully

Now need to figure out how to implement it and push via CMD
- Grabbed a newly provisioned HP Elitebook 10 
- Downloaded HP Support Assistant to see drivers that need to be updated (see sc)

<br>

![HPSA1](https://imgur.com/J07L2DK.jpg)
![HPSA2](https://imgur.com/VeqeV8w.jpg)

<br>

HP system information not gathering data 
- Under Drivers, it shows all drivers and bios that needs to be updated 
- Using Script Again Again to test to see what happens on a laptop that needs drivers

<br>

![Script1](https://imgur.com/zHRERnU.jpg)

<br>

> Ran it without the Bios Password and it did not go through successfully

<br>

![Script2](https://imgur.com/jkOlSA0.jpg)

<br> 

> Ran the command with the BIOS password again and it seems to continue going through. Need to figure out why it stops when I remove the Bios password.

After ~10 min the cmd terminal goes away
- No prompt for restart 
- After restarting took ~2 min before anything displayed
- But it is running through driver updates and installing

<br>

![Updates1](https://imgur.com/edCts5c.jpg)
![Updates2](https://imgur.com/40jQhs0.jpg)
![Updates3](https://imgur.com/j2cZyFO.jpg)

<br>

Will try script again to see if it may catch those
- Saying password Bios is set, will try again with an updated script soon
- Restarting

```
cmd /c PowerShell.exe -ExecutionPolicy Bypass -Command "Install-PackageProvider -Name NuGet -Force" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name PowerShellGet -SkipPublisherCheck -Force" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name HPCMSL -AcceptLicense -Force; mkdir C:\SWSetup; cd C:\SWSetup; Install-HPImageAssistant -Extract -DestinationPath 'C:\HPIA'; Set-HPBIOSSetupPassword -NewPassword '123456789'" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Write-HPFirmwarePasswordFile -password '2627838604' -outfile C:\SWSetup\currentbiossetuppwd.bin; Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList '/Operation:Download /Category:All /Selection:All /SoftpaqDownloadFolder:C:\SWSetup /noninteractive /ReportFolder:C:\Logs /BIOSPwdFile:C:\SWSetup\currentbiossetuppwd.bin' -NoNewWindow -Wait; New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Value HPIA -Force" ^

& rd /s /q C:\HPIA C:\SWSetup ^

& exit
```
```
cmd /c PowerShell.exe -ExecutionPolicy Bypass -Command "Install-PackageProvider -Name NuGet -Force" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name PowerShellGet -SkipPublisherCheck -Force" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name HPCMSL -AcceptLicense -Force; mkdir C:\SWSetup; cd C:\SWSetup; Install-HPImageAssistant -Extract -DestinationPath 'C:\HPIA'" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList '/Operation:Download /Category:All /Selection:All /SoftpaqDownloadFolder:C:\SWSetup /noninteractive /ReportFolder:C:\Logs' -NoNewWindow -Wait; New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Value HPIA -Force" ^

& rd /s /q C:\HPIA C:\SWSetup ^

& exit
```
```
cmd /c PowerShell.exe -ExecutionPolicy Bypass -Command "Install-PackageProvider -Name NuGet -Force" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name PowerShellGet -SkipPublisherCheck -Force" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name HPCMSL -AcceptLicense -Force; mkdir C:\SWSetup; cd C:\SWSetup; Install-HPImageAssistant -Extract -DestinationPath 'C:\HPIA'" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList '/Operation:Download /Category:DriverPack /Selection:All /SoftpaqDownloadFolder:C:\SWSetup /noninteractive /ReportFolder:C:\Logs' -NoNewWindow -Wait; New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Value HPIA -Force" ^

& rd /s /q C:\HPIA C:\SWSetup ^

& exit
```
> Was attempting to change the categories and what is targeted. I was following the official documentation here: [HP Image Assistant User Guide](https://ftp.hp.com/pub/caps-softpaq/cmit/whitepapers/HPIAUserGuide.pdf)

<br>

https://www.reddit.com/r/Hewlett_Packard/comments/18dc7z4/hp_image_assistant_user_prompt_restart/
```
C:\hpiasw\HPImageAssistant.exe /Operation:Analyze /Category:All /selection:All /Action:Install /Noninteractive /reportFolder:c:\hpiasw\report
```
Hmm I will see if there can be a prompt to restart

---

Attempting to install an older driver pack: **sp147159**

Using this cmd:
```
cmd /c PowerShell.exe -ExecutionPolicy Bypass -Command "Install-PackageProvider -Name NuGet -Force" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name PowerShellGet -SkipPublisherCheck -Force" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name HPCMSL -AcceptLicense -Force; mkdir C:\SWSetup; cd C:\SWSetup; Install-HPImageAssistant -Extract -DestinationPath 'C:\HPIA'" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList '/Operation:Download /SoftpaqID:sp147159 /SoftpaqDownloadFolder:C:\SWSetup /noninteractive /ReportFolder:C:\Logs' -NoNewWindow -Wait; New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Value HPIA -Force" ^

& rd /s /q C:\HPIA C:\SWSetup ^

& exit
```
---
<br>

Taking a step back and starting with the original reddit script . I only changed the function of the Bios password set, and specified softpaq 147159

<br>

```
cmd /c PowerShell.exe -ExecutionPolicy Bypass -Command "Install-PackageProvider -Name NuGet -Force" & PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name PowerShellGet -SkipPublisherCheck -Force" & PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name HPCMSL -AcceptLicense -Force; & mkdir C:\SWSetup; & cd C:\SWSetup; & Install-HPImageAssistant -Extract -DestinationPath 'C:\HPIA'" & PowerShell.exe -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList '/Operation:Scan /Category:All /Action:Download /SoftpaqDownloadFolder:C:\SWSetup /noninteractive /ReportFolder:C:\Logs' -NoNewWindow -Wait" & PowerShell.exe -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList '/Operation:Install /SoftpaqDownloadFolder:C:\SWSetup /noninteractive /ReportFolder:C:\Logs' -NoNewWindow -Wait; & New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Value HPIA -Force" & rd /s /q C:\HPIA C:\SWSetup & exit
```

<br>

> Attempted a restart after this, and no changes took place

Updated script to ensure ALL categories (BIOS, Drivers, Software, Firmware, Accessories) are targeted.
- Added Install type all "All: This option would indicate that all types of installable components should be installed"

<br>

```
cmd /c PowerShell.exe -ExecutionPolicy Bypass -Command "Install-PackageProvider -Name NuGet -Force" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name PowerShellGet -SkipPublisherCheck -Force" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name HPCMSL -AcceptLicense -Force; mkdir C:\SWSetup; cd C:\SWSetup; Install-HPImageAssistant -Extract -DestinationPath 'C:\HPIA'" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList '/Operation:Download /Category:BIOS,Drivers,Software,Firmware,Accessories /Selection:All /InstallType:All /SoftpaqDownloadFolder:C:\SWSetup /noninteractive /ReportFolder:C:\Logs' -NoNewWindow -Wait; New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Value HPIA -Force" ^

& rd /s /q C:\HPIA C:\SWSetup ^

& exit
```
<br>

> Updated with @echo

<br>

```
cmd /c PowerShell.exe -ExecutionPolicy Bypass -Command "Install-PackageProvider -Name NuGet -Force" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name PowerShellGet -SkipPublisherCheck -Force" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name HPCMSL -AcceptLicense -Force; mkdir C:\SWSetup; cd C:\SWSetup; Install-HPImageAssistant -Extract -DestinationPath 'C:\HPIA'" ^

& PowerShell.exe -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList '/Operation:Download /Category:BIOS,Drivers,Software,Firmware,Accessories /Selection:All /InstallType:All /SoftpaqDownloadFolder:C:\SWSetup /noninteractive /ReportFolder:C:\Logs' -NoNewWindow -Wait; New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Value HPIA -Force" ^

& rd /s /q C:\HPIA C:\SWSetup ^

& exit
```
<br>

> Converted to Powershell script:

<br>

```
# Set execution policy (avoid using cmd.exe)

Set-ExecutionPolicy Bypass -Scope CurrentUser

# Install NuGet provider (force if already exists)

Install-PackageProvider -Name NuGet -Force

# Install PowerShellGet module (skip publisher check, force if already exists)

Install-Module -Name PowerShellGet -SkipPublisherCheck -Force

# Install HPCMSL module (accept license, force if already exists)

Install-Module -Name HPCMSL -AcceptLicense -Force

# Create folders (optional, comment out if not needed)

# New-Item -Path C:\SWSetup -ItemType Directory

# New-Item -Path C:\Logs -ItemType Directory

# Extract HPIA (assuming HPIA is already installed)

# Install-HPImageAssistant -Extract -DestinationPath 'C:\HPIA'  # Only if not extracted yet

# Analyze system for updates in the background

Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList @(

  '/Operation:Analyze',

  '/Category:Drivers',  # Analyze drivers specifically

  '/Selection:All',

  '/Silent'  # Run silently in the background

) -Wait  # Wait for process to finish

# Optional: Download and install updates (modify arguments as needed)

 Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList @(

   '/Operation:Download',

   '/SoftpaqDownloadFolder:C:\SWSetup',  # Modify download folder if needed

   '/noninteractive',

   '/ReportFolder:C:\Logs'  # Modify report folder if needed

 ) -Wait

# Exit PowerShell

exit
```

<br>

> Went barebones for the execution script to see if it works. Will subject manager to test.

<br>

```
# Set execution policy (avoid using cmd.exe)

Set-ExecutionPolicy Bypass -Scope CurrentUser

# Install NuGet provider (force if already exists)

Install-PackageProvider -Name NuGet -Force

# Install PowerShellGet module (skip publisher check, force if already exists)

Install-Module -Name PowerShellGet -SkipPublisherCheck -Force

# Install HPCMSL module (accept license, force if already exists)

Install-Module -Name HPCMSL -AcceptLicense -Force

# Create temporary folders (optional, modify paths as needed)

New-Item -Path C:\SWSetup -ItemType Directory

New-Item -Path C:\Logs -ItemType Directory

# Download HPIA (assuming latest version)

$HPIAUrl = "https://ftp.ext.hp.com/pub/caps-softpaq/cmit/HPIA.html"

$HPIAFile = Invoke-WebRequest -Uri $HPIAUrl | Select-Object -ExpandProperty Content | Out-File -FilePath C:\SWSetup\HPIA.exe -Encoding ASCII

# Extract HPIA (assuming downloaded file is named HPIA.exe)

Expand-Archive -Path C:\SWSetup\HPIA.exe -DestinationPath C:\HPIA

# Analyze system for updates (focusing on drivers)

Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList @(

  '/Operation:Analyze',

  '/Category:Drivers',

  '/Silent'

) -Wait

# Check if updates are available (assuming success code stored in $LastExitCode)

if ($LastExitCode -eq 0) {

  # Download updates silently

  Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList @(

    '/Operation:Download',

    '/SoftpaqDownloadFolder:C:\SWSetup',  # Modify download folder if needed

    '/noninteractive',

    '/ReportFolder:C:\Logs',  # Modify report folder if needed

    '/Silent'

  ) -Wait

  # Install downloaded updates silently (might require reboot)

  Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList @(

    '/Operation:Install',

    '/Selection:All',  # Install all downloaded updates

    '/Silent'

  ) -Wait

  # Prompt for reboot if required (assuming flag in report)

  $reportPath = Get-ChildItem -Path C:\Logs -Filter "*.log" | Select-Object -Last 1  # Get latest log file

  $rebootRequired = Select-String -Path $reportPath -Pattern "Reboot Required"  # Check for reboot flag

  if ($rebootRequired.Matches.Count -gt 0) {

    Write-Host "A system reboot may be required to complete the update installation."

    Write-Host "Please save your work and reboot your system when ready."

  }

} else {

  # Write message if no updates found

  Write-Host "No driver updates found."

}

# Clean up (optional, comment out if needed)

# Remove-Item -Path C:\SWSetup -Recurse -Force

# Remove-Item -Path C:\HPIA -Recurse -Force

# Exit PowerShell

exit
```

<br>
---
<br>

> New Day New Testing :)
> Starting with this PS script:

<br>

```
# PowerShell script to automate HP drivers, firmware, and software updates



# Install NuGet package provider

cmd /c PowerShell.exe -ExecutionPolicy Bypass -Command "Install-PackageProvider -Name NuGet -Force"



# Install PowerShellGet module

cmd /c PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name PowerShellGet -SkipPublisherCheck -Force"



# Install HPCMSL module (HP Client Management Script Library)

cmd /c PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name HPCMSL -AcceptLicense -Force"



# Create directory for software setup

mkdir C:\SWSetup



# Change directory to software setup directory

cd C:\SWSetup



# Install HP Image Assistant and extract files

Install-HPImageAssistant -Extract -DestinationPath 'C:\HPIA'



# Start HP Image Assistant to analyze and install updates

Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' -ArgumentList '/Operation:Analyze /Category:All /Selection:All /Action:Install /SoftpaqDownloadFolder:C:\SWSetup /noninteractive /ReportFolder:C:\Logs' -NoNewWindow -Wait



# Clean up: Remove directories used for temporary files

rd /s /q C:\HPIA C:\SWSetup



# Exit the script

exit
```

![Test1](https://imgur.com/MwiCPTn.jpg)
![Test2](.jpg)
![Test3](.jpg)
