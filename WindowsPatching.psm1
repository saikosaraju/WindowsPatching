#######################################################################################################################
# File:             WindowsPatching.psm1                                                                              #
# Author:           Levon Becker                                                                                      #
# Email:			PowerShell.Guru@BonusBits.com                                                                     #
# Web Link:			http://www.bonusbits.com/wiki/HowTo:Use_Windows_Patching_PowerShell_Module                        #
# Publisher:        Bonus Bits                                                                                        #
# Copyright:        © 2012 Bonus Bits. All rights reserved.                                                           #
# Usage:            To load this module in PowerGUI Script Editor:                                                    #
#                   1. Open the Script Editor.                                                                        #
#                   2. Select "PowerShell Libraries" from the File menu.                                              #
#                   3. Check the WindowsPatching module.                                                              #
#                   4. Click on OK to close the "PowerShell Libraries" dialog.                                        #
#                   Alternatively you can load the module from the embedded console by invoking this:                 #
#                       Import-Module -Name WindowsPatching                                                           #
#######################################################################################################################

# SET MODULE PATH IN GLOBAL VARIABLE
[string]$Global:WindowsPatchingModulePath = $PSScriptRoot

#Validate user is an Administrator
Write-Verbose "Checking Administrator credentials"
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You are not running this as an Administrator!`nPlease re-run module with an Administrator Account."
    Break
}

# VALIDATE WSUS CONSOLE INSTALLED
Write-Verbose "Checking WSUS Console Installed Locally"
If (([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object {$_ -match "Microsoft.UpdateServices.Administration"}) -eq $null) {
	Clear
	Write-Host ''
	Write-Host "WSUS 3.0 Console is Not Installed Locally" -BackgroundColor Red -ForegroundColor White
	Write-Host ''
	Write-Host 'Steps to Install WSUS 3.0 Console Only'
	Write-Host '-------------------------------------------'
	Write-Host '1. Download The Install File from Microsoft'
	Write-Host '   http://www.microsoft.com/en-us/download/details.aspx?id=5216' -ForegroundColor Green
	Write-Host '2. Run Install Using the Following Command'
	Write-Host '   WSUS30-KB972455-x64.exe /q CONSOLE_INSTALL=1' -ForegroundColor Yellow
	Write-Host '    OR'
	Write-Host '   WSUS30-KB972455-x86.exe /q CONSOLE_INSTALL=1' -ForegroundColor Yellow
	Write-Host ''
	Break
}

# LOAD PARENT SCRIPTS
Try {
    Get-ChildItem -Path "$PSScriptRoot\ParentScripts\*.ps1" | Select-Object -ExpandProperty FullName | ForEach {
        # USED FOR EXCEPTION MESSAGE
		$Function = Split-Path $_ -Leaf
		# DOT SOURCE EACH SUBSCRIPT
        . $_
    }
} Catch {
    Write-Warning ("{0}: {1}" -f $Function,$_.Exception.Message)
    Continue
} 

# LOAD SUB SCRIPTS
Try {
    Get-ChildItem -Path "$PSScriptRoot\SubScripts\*.ps1" | Select-Object -ExpandProperty FullName | ForEach {
        # USED FOR EXCEPTION MESSAGE
		$Function = Split-Path $_ -Leaf
		# DOT SOURCE EACH SUBSCRIPT
        . $_
    }
} Catch {
    Write-Warning ("{0}: {1}" -f $Function,$_.Exception.Message)
    Continue
}   

# SHOW HEADER IF NO ARG 
If ( $Args.Length -gt 0 ) {
	$Script:NoHeader = $Args[0]
}

If ($Script:NoHeader -ne $true) {	
	Show-WindowsPatchingHeader
}



