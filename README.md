# HP Firmware Update Project
I'm tasked with figuring out a way to push HP driver updates to endpoint user laptops in the company.

## Summary
Need to develop a process for maintaining and deploying HP drivers to our laptop fleet. Not all drivers are released via windows update so using the driver update ring in Intune is not as ideal but could be an option to investigate. 

Also found the following blog posts that utilize HP Image assistant in conjunction with Intune to push out driver updates, this looks promising but will require research and testing. 

HP Developers Portal | Using HP Image Assistant with Microsoft Endpoint Manager

HP drivers with Intune and Proactive Remediations | scloud

## My Documentation from ClickUp
**DISCLAIMER: Most of the documentation below is my thought process and how I went from one point to another looking for information. A lot of it probably will not make too much sense.**

In summary, the Company Portal shows Configuration Manager-deployed applications for all co-managed clients that use it, while Software Center allows users to install and manage software on their devices.
> Was trying to figure out the difference between Company Portal and Software Center
https://www.reddit.com/r/sysadmin/comments/oca5vu/sccm_hp_mik_hp_patch_assistant/

https://www.reddit.com/r/SCCM/comments/zga6x9/how_do_yall_handle_firmware_updates/

Same here for Dell but for HP we automated the HPIA for local run via command line through Scheduled task.

-HP Image Assistant

-If you need to troubleshoot an end-user issue relating to the BIOS, BIOS settings, drivers, or software, you can run HPIA on the system to compare it to the corresponding HP reference image or any other known, good image XML file.

https://ftp.hp.com/pub/caps-softpaq/cmit/whitepapers/HPIAUserGuide.pdf



https://www.hp.com/us-en/solutions/client-management-solutions.html?jumpid=va_5b67f45b1f



https://www.hp.com/us-en/solutions/client-management-solutions/download.html?jumpid=va_5b67f45b1f



https://hpia.hpcloud.hp.com/downloads/driverpackcatalog/HP_Driverpack_Matrix_x64.html?jumpid=va_5b67f45b1f



Next steps figure out HP Image Assistant

https://support.hp.com/us-en/document/ish_7636709-7636753-16



Link for HPIA download: https://hpia.hpcloud.hp.com/downloads/hpia/hp-hpia-5.2.1.exe?jumpid=va_5b67f45b1f



Possible cmd to run:

https://www.reddit.com/r/Hewlett_Packard/comments/r11637/hp_image_assistant_driver_maintenance/
