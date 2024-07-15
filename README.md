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

![HP System](https://imgur.com/CuAwCxe.jpg)
![HP System 2](https://imgur.com/egihQfp.jpg)
