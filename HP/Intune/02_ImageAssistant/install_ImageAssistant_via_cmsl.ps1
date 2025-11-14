#requires cmsl (https://github.com/kranzerj/Intune/blob/main/update_oem_firmware_client/hp/01_install_cmsl.ps1       
#https://developers.hp.com/hp-client-management) 
#Detection rule: File: C:\HPI\HPImageAssistant.exe exists
#uninstall Command: powershell .....: Remove-Item C:\HPI -Recurse

Import-Module HP.Softpaq
Install-HPImageAssistant -Extract "C:\Program Files\HPImageAssistant" -Quiet
