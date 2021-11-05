# PowerShell Software Packaging Wrapper

![GitHub repo size](https://img.shields.io/github/repo-size/niklasrast/MEM-Application-Packaging-Wrapper)

![GitHub issues](https://img.shields.io/github/issues-raw/niklasrast/MEM-Application-Packaging-Wrapper)

![GitHub last commit](https://img.shields.io/github/last-commit/niklasrast/MEM-Application-Packaging-Wrapper)

This repo contains an powershell scripts to create an wrapping script in powershell to install, uninstall and detect applications through any software deployment solution. My choose for the software deployment solution is Microsoft Intune. After you´ve created the script to deploy the package you can use it to deploy the application on your Windows 10 clients.

Replace MANUFACTURER-APPLICATION with the Manufacturer and Name of the application. This will also be the details for the package registration in HKLM:\SOFTWARE\OS. Update the version number

## Install:
Select if you want to install your application based on EXE or MSI. You can also add File/Folder or RegKey/Value´s. It is posible to use multiple calls in the $install section.
```powershell
#Install EXE or MSI
Start-Process -FilePath "$PSScriptRoot\" -ArgumentList '/qn /l* "C:\Windows\Logs\INSTALL-MANUFACTURER-APPLICATION-Application.log"' -Wait

#Add File or Folder
Copy-Item -Path "$PSScriptRoot\" -Destination "" -Recurse -Force

#Add RegKey
New-Item -Path "HKLM:\SOFTWARE\" -Name "" -Force

#Add RegKeyValue
New-ItemProperty "HKLM:\SOFTWARE\" -Name "" -PropertyType "String" -Value "" -Force
```

### Package registration in registry
```powershell
#Register package in registry
New-Item -Path "HKLM:\SOFTWARE\OS\" -Name "MANUFACTURER-APPLICATION"
New-ItemProperty -Path "HKLM:\SOFTWARE\OS\MANUFACTURER-APPLICATION" -Name "Version" -PropertyType "String" -Value "1.0.0" -Force
```

## Uninstall:
Select if you want to uninstall your application based on EXE or MSI. You can also remove File/Folder or RegKey/Value´s. It is posible to use multiple calls in the $uninstall section.
```powershell
#Uninstall EXE
Start-Process -FilePath "" -ArgumentList '' -Wait

#Uninstall MSI
Start-Process -FilePath msiexec.exe -ArgumentList '/x "{}" /qn /l* "C:\Windows\Logs\UNINSTALL-MANUFACTURER-APPLICATION-Application.log"' -Wait

#Remove File or Folder
Remove-Item -Path "" -Recurse -Force

#Remove RegKey
Remove-Item -Path "HKLM:\SOFTWARE\" -Recurse -Force

#Remove RegKeyValue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\" -Name ""

#Remove package registration in registry
Remove-Item -Path "HKLM:\SOFTWARE\OS\MANUFACTURER-APPLICATION" -Recurse -Force 
```

### Software distribution (Microsoft Intune)
####  Details: 
- Name: Name of the software package
- Description: Name, Version, UI-language and Download size
- Publisher: Developer and (Productowner at your company)
- App Version: Version of the application package
- Information URL: http://Basis or http://Genehmigungsfrei or http://Genehmigungspflichtig
- Developer: Name of the packaging agent
- Owner: Number of the SRQ or INC
- Notes: Package class (Small, Medium or Complex)
- Add a picture

![Alt text](https://github.com/niklasrast/MEM-Application-Packaging-Wrapper/blob/main/img/mem-app-01.png "App informations")

#### Install and Uninstall:
- Install: C:\Windows\SysNative\WindowsPowershell\v1.0\PowerShell.exe -ExecutionPolicy Bypass -Command .\INSTALL-MANUFACTURER-APPLICATION.ps1 -install
- Uninstall: C:\Windows\SysNative\WindowsPowershell\v1.0\PowerShell.exe -ExecutionPolicy Bypass -Command .\INSTALL-MANUFACTURER-APPLICATION.ps1 -uninstall
- Restart behavior: Select on what your package needs

![Alt text](https://github.com/niklasrast/MEM-Application-Packaging-Wrapper/blob/main/img/mem-app-02.png "App informations")

#### Requirements:
- OS architecture: Select 32- and 64bit
- Minimum OS version: Select the oldest windows version that you manage

![Alt text](https://github.com/niklasrast/MEM-Application-Packaging-Wrapper/blob/main/img/mem-app-03.png "App informations")

#### Detection
- Rule format: Manually
- Type: Registry
- Key path: HKLM\SOFTWARE\OS\MANUFACTURER-APPLICATION
- Value: Version
- Detection: String comparison
- Operator: Equals
- Value: Version of the application package

![Alt text](https://github.com/niklasrast/MEM-Application-Packaging-Wrapper/blob/main/img/mem-app-04.png "App informations")

### Parameter definitions:
- -install installs the application on the windows client.
- -uninstall removes the application from the windows client.
 
## Logfiles:
The scripts create a logfile with the name of the .ps1 script in the folder C:\Windows\Logs.

## Requirements:
- PowerShell 5.0
- Windows 10 or later
 
# Feature requests
If you have an idea for a new feature in this repo, send me an issue with the subject Feature request and write your suggestion in the text. I will then check the feature and implement it if necessary.

Created by @niklasrast 
