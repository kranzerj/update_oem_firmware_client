# Solutions for updating proprietary drivers and firmware on Windows clients 
***
Mostly created by Maximilian ‘Max’ Böhler, Josef ‘Josy’ Kranzer (both COUNT IT), and OpenAI ChatGPT.
In the final stage of development, a solution for Intune (unless otherwise specified as a Windows app) and Group Policy (unless otherwise specified as a computer startup script) should be available for HP, Lenovo, and Dell. 
This is not currently the case, and the guide is not yet complete. 
***

### HP 

#### Intune
###### Status: complete
###### Dynamic membership rule: (device.deviceManufacturer -eq "HP")

Dock firmware is excluded from basic updates to achieve better notifications for end users.
Intune Win32 apps built on each other. 
App04 dependencies App03 (Automatically Install) 
App 03 dependencies AP02...
Therefore, it is enough to configure an assignment for the 04_HP_Dockupdate.

#### Group Policy
###### Status: functional, excluding dock updates is pending
###### WMI Filter: root\CIMv2        select * from Win32_ComputerSystem where Manufacturer like "HP%"
***
### Lenovo

#### Intune
###### Status: complete
###### Dynamic membership rule: (device.deviceManufacturer -eq "Lenovo")

#### Group Policy
###### Status: complete
###### WMI Filter: root\CIMv2        select * from Win32_ComputerSystem where Manufacturer like "LENOVO%"
Copy the Task Script via Group Policy to Computer- See at the README (https://github.com/kranzerj/update_oem_firmware_client/tree/main/Lenovo/GPO#readme)  


