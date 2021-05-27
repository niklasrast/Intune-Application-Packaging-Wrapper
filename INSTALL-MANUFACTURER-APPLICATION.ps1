<#
    .SYNOPSIS 
    Windows 10 Software packaging wrapper

    .DESCRIPTION
    Install:   PowerShell.exe -ExecutionPolicy Bypass -Command .\INSTALL-MANUFACTURER-APPLICATION.ps1 -install
    Uninstall: PowerShell.exe -ExecutionPolicy Bypass -Command .\INSTALL-MANUFACTURER-APPLICATION.ps1 -uninstall
    Detect:    PowerShell.exe -ExecutionPolicy Bypass -Command .\INSTALL-MANUFACTURER-APPLICATION.ps1 -detect

    .ENVIRONMENT
    PowerShell 5.0

    .AUTHOR
    Niklas Rast
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $true, ParameterSetName = 'install')]
	[switch]$install,
	[Parameter(Mandatory = $true, ParameterSetName = 'uninstall')]
	[switch]$uninstall,
	[Parameter(Mandatory = $true, ParameterSetName = 'detect')]
	[switch]$detect
)

$ErrorActionPreference = "SilentlyContinue"
#Use "C:\Windows\Logs" for System Installs and "$env:TEMP" for User Installs
$logFile = ('{0}\{1}.log' -f "C:\Windows\Logs", [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))

if ($install)
{
    Start-Transcript -path $logFile -Append
        try
        {         
            #Install EXE
            Start-Process -FilePath "$PSScriptRoot\" -ArgumentList '' -Wait

            #Install MSI
            Start-Process -FilePath msiexec.exe -ArgumentList '/i "{}" /qn /l* "C:\Windows\Logs\INSTALL-MANUFACTURER-APPLICATION.log"' -Wait

            #Add File or Folder
            Copy-Item -Path "$PSScriptRoot\" -Destination "" -Recurse -Force

            #Add RegKey
            New-Item -Path "HKLM:\SOFTWARE\" -Name "" -Force

            #Add RegKeyValue
            New-ItemProperty "HKLM:\SOFTWARE\" -Name "" -PropertyType "String" -Value "" -Force

            return $true        
        } 
        catch
        {
            $PSCmdlet.WriteError($_)
            return $false
        }
    Stop-Transcript
}

if ($uninstall)
{
    Start-Transcript -path $logFile -Append
        try
        {
            #Uninstall EXE
            Start-Process -FilePath "" -ArgumentList '' -Wait

            #Uninstall MSI
            Start-Process -FilePath msiexec.exe -ArgumentList '/x "{}" /qn /l* "C:\Windows\Logs\UNINSTALL-MANUFACTURER-APPLICATION.log"' -Wait

            #Remove File or Folder
            Remove-Item -Path "" -Recurse -Force

            #Remove RegKey
            Remove-Item -Path "HKLM:\SOFTWARE\" -Recurse -Force

            #Remove RegKeyValue
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\" -Name ""

            return $true     
        }
        catch
        {
            $PSCmdlet.WriteError($_)
            return $false
        }
    Stop-Transcript
}

if ($detect)
{
    Start-Transcript -path $logFile -Append
        try {
            #Detect File or Folder
            $detection = (Test-Path -Path "")

            #Detect RegKeyValue
            $detection = (Get-ItemProperty -Path "HKLM:\SOFTWARE\" | Select-Object -ExpandProperty "")

            #Detect MSI ProductCode
            $detection = (Get-WmiObject -class Win32_Product | Where-Object IdentifyingNumber -match "{}")

            return $detection
        }
        catch {
            $PSCmdlet.WriteError($_)
            return $false
        }
    Stop-Transcript
}