<#
    .SYNOPSIS 
    Create a new copy of the PowerShell Package wrapper script

    .DESCRIPTION
    Run: .\Create-NewPackageWrapper.ps1
    
    .ENVIRONMENT
    PowerShell 5.0
    
    .AUTHOR
    Niklas Rast

    .GITHUB
    https://github.com/niklasrast/Intune-Application-Packaging-Wrapper
#>

param (
    [Parameter(Mandatory=$true)] 
    [String] $OutputFile = ""
)

$WrapperScript=@'
<#
    .SYNOPSIS 
    Windows Software packaging wrapper

    .DESCRIPTION
    Install:   C:\Windows\SysNative\WindowsPowershell\v1.0\PowerShell.exe -ExecutionPolicy Bypass -Command .\INSTALL-MANUFACTURER-APPLICATION.ps1 -install
    Uninstall: C:\Windows\SysNative\WindowsPowershell\v1.0\PowerShell.exe -ExecutionPolicy Bypass -Command .\INSTALL-MANUFACTURER-APPLICATION.ps1 -uninstall
    
    .ENVIRONMENT
    PowerShell 5.0
    
    .AUTHOR
    Niklas Rast

    .CLASS
    SMALL | MEDIUM | COMPLEX
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $true, ParameterSetName = 'install')]
	[switch]$install,
	[Parameter(Mandatory = $true, ParameterSetName = 'uninstall')]
	[switch]$uninstall
)

$ErrorActionPreference = "SilentlyContinue"
#Use "C:\Windows\Logs" for System Installs and "$env:TEMP" for User Installs
$logFile = ('{0}\{1}.log' -f "C:\Windows\Logs", [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))

#Test if registry folder exists
if ($true -ne (test-Path -Path "HKLM:\SOFTWARE\COMPANY")) {
    New-Item -Path "HKLM:\SOFTWARE\" -Name "COMPANY" -Force
}

if ($install)
{
    Start-Transcript -path $logFile -Append
        try
        {         
            #Install EXE or MSI
            Start-Process -FilePath "$PSScriptRoot\" -ArgumentList '/qn /l* "C:\Windows\Logs\INSTALL-MANUFACTURER-APPLICATION-Application.log"' -Wait

            #Add File or Folder
            Copy-Item -Path "$PSScriptRoot\" -Destination "" -Recurse -Force

            #Add RegKey
            New-Item -Path "HKLM:\SOFTWARE\" -Name "" -Force

            #Add RegKeyValue
            New-ItemProperty "HKLM:\SOFTWARE\" -Name "" -PropertyType "String" -Value "" -Force

            #Register package in registry
            New-Item -Path "HKLM:\SOFTWARE\COMPANY\" -Name "MANUFACTURER-APPLICATION"
            New-ItemProperty -Path "HKLM:\SOFTWARE\COMPANY\MANUFACTURER-APPLICATION" -Name "Version" -PropertyType "String" -Value "1.0.0" -Force

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
            Start-Process -FilePath msiexec.exe -ArgumentList '/x "{}" /qn /l* "C:\Windows\Logs\UNINSTALL-MANUFACTURER-APPLICATION-Application.log"' -Wait

            #Remove File or Folder
            Remove-Item -Path "" -Recurse -Force

            #Remove RegKey
            Remove-Item -Path "HKLM:\SOFTWARE\" -Recurse -Force

            #Remove RegKeyValue
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\" -Name ""

            #Remove package registration in registry
            Remove-Item -Path "HKLM:\SOFTWARE\COMPANY\MANUFACTURER-APPLICATION" -Recurse -Force 

            return $true     
        }
        catch
        {
            $PSCmdlet.WriteError($_)
            return $false
        }
    Stop-Transcript
}
'@


if ($OutputFile -like "*.ps1") {
    Add-Content -Path $OutputFile -Value $WrapperScript -Force -Confirm:$false
    Write-Host -ForegroundColor Green "Successfully created a new wrapper at $OutputFile"
} else {
    Write-Error "Invalid OutputFile name! Please ensure that the filename ends with '.ps1'"
}