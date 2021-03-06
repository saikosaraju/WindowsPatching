﻿#requires –version 2.0

Function Move-WSUSClientToGroup {

#region Help

<#
.SYNOPSIS
	Get list of WSUS Clients by WSUS Group.
.DESCRIPTION
	Get list of WSUS Clients by WSUS Group.
.NOTES
	VERSION:    1.0.3
	AUTHOR:     Levon Becker
	EMAIL:      PowerShell.Guru@BonusBits.com 
	ENV:        Powershell v2.0, CLR 2.0+
	TOOLS:      PowerGUI Script Editor
.INPUTS
	ComputerName    Single Hostname
	List            List of Hostnames
	FileName        File with List of Hostnames
	FileBrowser     File with List of Hostnames
	
	DEFAULT FILENAME PATH
	---------------------
	HOSTLISTS
	%USERPROFILE%\Documents\HostList
.OUTPUTS
	DEFAULT PATHS
	-------------
	RESULTS
	%USERPROFILE%\Documents\Results\Move-WSUSClientToGroup
	
	LOGS
	%USERPROFILE%\Documents\Logs\Move-WSUSClientToGroup
	+---History
	+---JobData
	+---Latest
	+---WIP
.EXAMPLE
	Move-WSUSClientToGroup -ComputerName server01  -TargetGroup group01
	Move a single computer to another WSUS Group.
	The destination group must already exist.
.EXAMPLE
	Move-WSUSClientToGroup server01 -TargetGroup group01
	Move a single computer to another WSUS Group.
	The destination group must already exist.
.EXAMPLE
	Move-WSUSClientToGroup -List server01,server02 -TargetGroup group01
	Move a list of computers to another WSUS Group.
	The destination group must already exist.
.EXAMPLE
	Move-WSUSClientToGroup -List $MyHostList  -TargetGroup group01
	Move a list of computers to another WSUS Group using an array of hostnames.
	The destination group must already exist.
	i.e. $MyHostList = @("server01","server02","server03")
.EXAMPLE
	Move-WSUSClientToGroup -FileBrowser  -TargetGroup group01
	This switch will launch a separate file browser window.
	In the window you can browse and select a text or csv file from anywhere
	accessible by the local computer that has a list of host names.
	The host names need to be listed one per line or comma separated.
	This list of system names will be used to perform the script tasks for 
	each host in the list.
.EXAMPLE
	Move-WSUSClientToGroup -FileBrowser -SkipOutGrid -TargetGroup group01
	FileBrowser:
		This switch will launch a separate file browser window.
		In the window you can browse and select a text or csv file from anywhere
		accessible by the local computer that has a list of host names.
		The host names need to be listed one per line or comma separated.
		This list of system names will be used to perform the script tasks for 
		each host in the list.
	SkipOutGrid:
		This switch will skip the results poppup windows at the end.
.PARAMETER ComputerName
	Short name of Windows host to patch
	Do not use FQDN 
.PARAMETER List
	A PowerShell array List of servers to patch or comma separated list of host
	names to perform the script tasks on.
	-List server01,server02
	@("server1", "server2") will work as well
	Do not use FQDN
.PARAMETER FileBrowser
	This switch will launch a separate file browser window.
	In the window you can browse and select a text or csv file from anywhere
	accessible by the local computer that has a list of host names.
	The host names need to be listed one per line or comma separated.
	This list of system names will be used to perform the script tasks for 
	each host in the list.
.PARAMETER TargetGroup
	Target WSUS Group name to move computer or computers too.
.PARAMETER UpdateServer
	WSUS server hostname. 
	Short or FQDN works.
.PARAMETER UpdateServerPort
	TCP Port number to connect to the WSUS Server through IIS.
.PARAMETER SkipOutGrid
	This switch will skip displaying the end results that uses Out-GridView.
.LINK
	http://www.bonusbits.com/wiki/HowTo:Use_Windows_Patching_PowerShell_Module
	http://www.bonusbits.com/wiki/HowTo:Enable_.NET_4_Runtime_for_PowerShell_and_Other_Applications
	http://www.bonusbits.com/wiki/HowTo:Setup_PowerShell_Module
	http://www.bonusbits.com/wiki/HowTo:Enable_Remote_Signed_PowerShell_Scripts
#>

#endregion Help

#region Parameters

	[CmdletBinding()]
	Param (
		[parameter(Mandatory=$false,Position=0)][string]$ComputerName,
		[parameter(Mandatory=$false)][array]$List,
		[parameter(Mandatory=$false)][switch]$FileBrowser,
		[parameter(Mandatory=$false,Position=1)][string]$TargetGroup,
		[parameter(Mandatory=$false)][string]$UpdateServer,
		[parameter(Mandatory=$false)][int]$UpdateServerPort,
		[parameter(Mandatory=$false)][switch]$SkipOutGrid
	)

#endregion Parameters

	If (!$Global:WindowsPatchingDefaults) {
		Show-WindowsPatchingErrorMissingDefaults
	}
	
	# SET MISSING PARAMETERS
	If (!$UpdateServer) {
		[string]$UpdateServer = ($Global:WindowsPatchingDefaults.UpdateServer)
	}
	
	If (!$UpdateServerPort) {
		[int]$UpdateServerPort = ($Global:WindowsPatchingDefaults.UpdateServerPort)
	}

	# GET STARTING GLOBAL VARIABLE LIST
	New-Variable -Name StartupVariables -Force -Value (Get-Variable -Scope Global | Select -ExpandProperty Name)
	
	# CAPTURE CURRENT TITLE
	[string]$StartingWindowTitle = $Host.UI.RawUI.WindowTitle
	
	# PATHS NEEDED AT TOP
	[string]$HostListPath = ($Global:WindowsPatchingDefaults.HostListPath)
	
#region Prompt: Missing Input

	#region Prompt: FileBrowser
	
		If ($FileBrowser.IsPresent -eq $true) {
			Clear
			Write-Host 'SELECT FILE CONTAINING A LIST OF HOSTS TO PATCH.'
			Get-FileName -InitialDirectory $HostListPath -Filter "Text files (*.txt)|*.txt|Comma Delimited files (*.csv)|*.csv|All files (*.*)|*.*"
			[string]$FileName = $Global:GetFileName.FileName
			[string]$HostListFullName = $Global:GetFileName.FullName
		}
	
	#endregion Prompt: FileBrowser

	#region Prompt: Host Input

		If (!($FileName) -and !($ComputerName) -and !($List)) {
			[boolean]$HostInputPrompt = $true
			Clear
			$promptitle = ''
			
			$message = "Please Select a Host Entry Method:`n"
			
			# HM = Host Method
			$hmc = New-Object System.Management.Automation.Host.ChoiceDescription "&ComputerName", `
			    'Enter a single hostname'

			$hml = New-Object System.Management.Automation.Host.ChoiceDescription "&List", `
			    'Enter a List of hostnames separated by a commna without spaces'
				
			$hmf = New-Object System.Management.Automation.Host.ChoiceDescription "&File", `
			    'Text file name that contains a List of ComputerNames'
			
			$exit = New-Object System.Management.Automation.Host.ChoiceDescription "E&xit", `
			    'Exit Script'

			$options = [System.Management.Automation.Host.ChoiceDescription[]]($hmc, $hml, $hmf, $exit)
			
			$result = $host.ui.PromptForChoice($promptitle, $message, $options, 3) 
			
			# RESET WINDOW TITLE AND BREAK IF EXIT SELECTED
			If ($result -eq 3) {
				Clear
				Reset-WindowsPatchingUI -StartingWindowTitle $StartingWindowTitle -StartupVariables $StartupVariables -SkipPrompt
				Break
			}
			Else {
			Switch ($result)
				{
				    0 {$HostInputMethod = 'ComputerName'} 
					1 {$HostInputMethod = 'List'}
					2 {$HostInputMethod = 'File'}
				}
			}
			Clear
			
			# PROMPT FOR COMPUTERNAME
			If ($HostInputMethod -eq 'ComputerName') {
				Do {
					Clear
					Write-Host ''
#					Write-Host 'Short name of a single host.'
					$ComputerName = $(Read-Host -Prompt 'ENTER COMPUTERNAME')
				}
				Until ($ComputerName)
			}
			# PROMPT FOR LIST 
			Elseif ($HostInputMethod -eq 'List') {
				Write-Host 'Enter a List of hostnames separated by a comma without spaces to patch.'
				$commaList = $(Read-Host -Prompt 'Enter List')
				# Read-Host only returns String values, so need to split up the hostnames and put into array
				[array]$List = $commaList.Split(',')
			}
			# PROMPT FOR FILE
			Elseif ($HostInputMethod -eq 'File') {
				Clear
				Write-Host ''
				Write-Host 'SELECT FILE CONTAINING A LIST OF HOSTS TO PATCH.'
				Get-FileName -InitialDirectory $HostListPath -Filter "Text files (*.txt)|*.txt|Comma Delimited files (*.csv)|*.csv|All files (*.*)|*.*"
				[string]$FileName = $Global:GetFileName.FileName
				[string]$HostListFullName = $Global:GetFileName.FullName
			}
			Else {
				Write-Host 'ERROR: Host method entry issue'
				Reset-WindowsPatchingUI -StartingWindowTitle $StartingWindowTitle -StartupVariables $StartupVariables
				Break
			}
		}
		
	#endregion Prompt: Host Input
	
	#region Prompt: Target Group
	
		If (!$TargetGroup) {
			Do {
				Clear
				Write-Host ''
				$TargetGroup = $(Read-Host -Prompt 'ENTER DESTINATION GROUP NAME')
			}
			Until ($TargetGroup)
		}
	
	#endregion Prompt: Target Group

#endregion Prompt: Missing Input

#region Variables

	# DEBUG
	$ErrorActionPreference = "Inquire"
	
	# SET ERROR MAX LIMIT
	$MaximumErrorCount = '1000'
	$Error.Clear()

	# SCRIPT INFO
	[string]$ScriptVersion = '1.0.4'
	[string]$ScriptTitle = "Move WSUS Clients to a Different WSUS Group by Levon Becker"
	[int]$DashCount = '60'

	# CLEAR VARIABLES
	[int]$TotalHosts = 0

	# LOCALHOST
	[string]$ScriptHost = $Env:COMPUTERNAME
	[string]$UserDomain = $Env:USERDOMAIN
	[string]$UserName = $Env:USERNAME
	[string]$FileDateTime = Get-Date -UFormat "%Y-%m%-%d_%H.%M"
	[datetime]$ScriptStartTime = Get-Date
	$ScriptStartTimeF = Get-Date -Format g

	# DIRECTORY PATHS
	[string]$ResultsPath = ($Global:WindowsPatchingDefaults.MoveWSUSClientToGroupResultsPath)
	
	[string]$ModuleRootPath = $Global:WindowsPatchingModulePath
	[string]$SubScripts = Join-Path -Path $ModuleRootPath -ChildPath 'SubScripts'
	[string]$Assets = Join-Path -Path $ModuleRootPath -ChildPath 'Assets'
	
	#region  Set Logfile Name + Create HostList Array
	
		If ($ComputerName) {
			[string]$InputDesc = $ComputerName.ToUpper()
			# Inputitem is also used at end for Outgrid
			[string]$InputItem = $ComputerName.ToUpper() #needed so the WinTitle will be uppercase
			[array]$HostList = $ComputerName.ToUpper()
		}
		ElseIF ($List) {
			[array]$List = $List | ForEach-Object {$_.ToUpper()}
			[string]$InputDesc = "LIST - " + ($List | Select -First 2) + " ..."
			[string]$InputItem = "LIST: " + ($List | Select -First 2) + " ..."
			[array]$HostList = $List
		}		
		ElseIf ($FileName) {
			[string]$InputDesc = $FileName
			# Inputitem used for WinTitle and Out-GridView Title at end
			[string]$InputItem = $FileName
			If ((Test-Path -Path $HostListFullName) -ne $true) {
					Clear
					Write-Host ''
					Write-Host "ERROR: INPUT FILE NOT FOUND ($HostListFullName)" -ForegroundColor White -BackgroundColor Red
					Write-Host ''
					Reset-WindowsPatchingUI -StartingWindowTitle $StartingWindowTitle -StartupVariables $StartupVariables
					Break
			}
			[array]$HostList = Get-Content $HostListFullName
			[array]$HostList = $HostList | ForEach-Object {$_.ToUpper()}
		}
		Else {
			Clear
			Write-Host ''
			Write-Host "ERROR: INPUT METHOD NOT FOUND" -ForegroundColor White -BackgroundColor Red
			Write-Host ''
			Reset-WindowsPatchingUI -StartingWindowTitle $StartingWindowTitle -StartupVariables $StartupVariables
			Break
		}
		# Remove Duplicates in Array + Get Host Count
		[array]$HostList = $HostList | Select -Unique
		[int]$TotalHosts = $HostList.Count
	
	#endregion Set Logfile Name + Create HostList Array
	
	#region Determine TimeZone
	
		Get-TimeZone -ComputerName 'Localhost'
		
		If (($Global:GetTimeZone.Success -eq $true) -and ($Global:GetTimeZone.ShortForm -ne '')) {
			[string]$TimeZone = $Global:GetTimeZone.ShortForm
			[string]$TimeZoneString = "_" + $Global:GetTimeZone.ShortForm
		}
		Else {
			[string]$TimeZoneString = ''
		}
	
	#endregion Determine TimeZone

	# FILENAMES
	[string]$ResultsTextFileName = "Move-WSUSClientToGroup_Results_" + $FileDateTime + $TimeZoneString + "_($InputDesc).log"
	[string]$ResultsCSVFileName = "Move-WSUSClientToGroup_Results_" + $FileDateTime + $TimeZoneString + "_($InputDesc).csv"

	# PATH + FILENAMES
	[string]$ResultsTextFullName = Join-Path -Path $ResultsPath -ChildPath $ResultsTextFileName
	[string]$ResultsCSVFullName = Join-Path -Path $ResultsPath -ChildPath $ResultsCSVFileName

	# MISSING PARAMETERS
	If (!$UpdateServer) {
		[string]$UpdateServer = ($Global:WindowsPatchingDefaults.UpdateServer)
	}


#endregion Variables

#region Check Dependencies
	
	# Create Array of Paths to Dependancies to check
#	CLEAR
	$DependencyList = @(
		"$ResultsPath",
		"$SubScripts",
		"$Assets"
	)

	[array]$MissingDependencyList = @()
	Foreach ($Dependency in $DependencyList) {
		[boolean]$CheckPath = $false
		$CheckPath = Test-Path -Path $Dependency -ErrorAction SilentlyContinue 
		If ($CheckPath -eq $false) {
			$MissingDependencyList += $Dependency
		}
	}
	$MissingDependencyCount = ($MissingDependencyList.Count)
	If ($MissingDependencyCount -gt 0) {
		Clear
		Write-Host ''
		Write-Host "ERROR: Missing $MissingDependencyCount Dependencies" -ForegroundColor White -BackgroundColor Red
		Write-Host ''
		$MissingDependencyList
		Write-Host ''
		Reset-WindowsPatchingUI -StartingWindowTitle $StartingWindowTitle -StartupVariables $StartupVariables
		Break
	}

#endregion Check Dependencies

#region Show Window Title

	Set-WinTitleStart -Title $ScriptTitle
	Show-ScriptHeader -BlankLines '1' -DashCount $DashCount -ScriptTitle $ScriptTitle
#	Add-StopWatch
#	Start-Stopwatch

#endregion Show Window Title

#region Console Start Statements
	
	Show-ScriptHeader -BlankLines '4' -DashCount $DashCount -ScriptTitle $ScriptTitle
	# Get PowerShell Version with External Script
	Set-WinTitleBase -ScriptVersion $ScriptVersion 
	[datetime]$ScriptStartTime = Get-Date
	[string]$ScriptStartTimeF = Get-Date -Format g

#endregion Console Start Statements

#region Update Window Title

	Set-WinTitleInput -WinTitleBase $Global:WinTitleBase -InputItem $InputItem
	Show-ScriptHeader -BlankLines '1' -DashCount $DashCount -ScriptTitle $ScriptTitle
	
#endregion Update Window Title

#region Tasks

	#region Load PoshWSUS Module
	
		# CHECK IF MODULE LOADED ALREADY
		If ((Get-Module | Select-Object -ExpandProperty Name | Out-String) -match "PoshWSUS") {
			[Boolean]$ModLoaded = $true
		}
		Else {
			[Boolean]$ModLoaded = $false
		}
		
		# IF MODULE NOT LOADED THEN CHECK IF ON SYSTEM
		If ($ModLoaded -ne $true) {
			Try {
				Import-Module -Name "$ModuleRootPath\Modules\PoshWSUS\PoshWSUS.psd1" -ErrorAction Stop | Out-Null
				[Boolean]$ModLoaded = $true
			}
			Catch {
				[Boolean]$ModLoaded = $false
				Write-Host ''
				Write-Host "ERROR: Failed to Load PoshWSUS Module" -ForegroundColor White -BackgroundColor Red
				Write-Host ''
				Reset-WindowsPatchingUI -StartingWindowTitle $StartingWindowTitle -StartupVariables $StartupVariables
				Break
			}
		}
	
	#endregion Load PoshWSUS Module
	
	#region Connect to WSUS Server
	
		If ($ModLoaded -eq $true) {
			Try {
				Connect-WSUSServer -WsusServer $UpdateServer -port $UpdateServerPort -ErrorAction Stop | Out-Null
				[Boolean]$WSUSConnected = $true
			}
			Catch {
				[Boolean]$WSUSConnected = $false
				Write-Host ''
				Write-Host "ERROR: Failed to Connect to WSUS Server ($UpdateServer)" -ForegroundColor White -BackgroundColor Red
				Write-Host ''
				Reset-WindowsPatchingUI -StartingWindowTitle $StartingWindowTitle -StartupVariables $StartupVariables
				Break
			}
		}
	
	#endregion Connect to WSUS Server
	
	#region Main Tasks
	
		If ($WSUSConnected -eq $true) {
		
			#region Verify Destination Group Exists
			
				[array]$WSUSServerGroups = Get-WSUSGroup | Select-Object -ExpandProperty Name
				If ($WSUSServerGroups -notcontains $TargetGroup) {
					Write-Host ''
					Write-Host "ERROR: WSUS Group ($TargetGroup) does not exist on $UpdateServer" -BackgroundColor Red -ForegroundColor White
					Write-Host ''
					Reset-WindowsPatchingUI -StartingWindowTitle $StartingWindowTitle -StartupVariables $StartupVariables
					Break
				}
				
			#endregion Verify Destination Group Exists
		
			#region Loop
		
				[int]$HostCount = $HostList.Count
				$i = 0
				[int]$TotalHosts = 0
				[array]$Results = @()
				Foreach ($ComputerName in $HostList) {
					$TaskProgress = [int][Math]::Ceiling((($i / $HostCount) * 100))
					# Progress Bar
					Write-Progress -Activity "STARTING WSUS CLIENT GROUP MOVE ON - ($ComputerName)" -PercentComplete $TaskProgress -Status "OVERALL PROGRESS - $TaskProgress%"
					
					#region Verify Computer Exists in WSUS
						
						$WSUSClient = Get-WSUSClient -Computer $ComputerName
						[Boolean]$ComputerFound = $false
						If (($WSUSClient -ne $null) -and ($WSUSClient -ne '')) {
							[Boolean]$ComputerFound = $true
						}
						Else {
							[Boolean]$ComputerFound = $false
						}
					
					#endregion Verify Computer Exists in WSUS
					
					If ($ComputerFound -eq $true) {
					
					#region Get Source Group
					
						[array]$SourceGroups = Get-WSUSClient -Computer $ComputerName | Select-Object -ExpandProperty ComputerGroup
						[array]$FilteredGroups = @()
						Foreach ($Source in $SourceGroups) {
							If ($Source -notmatch 'All Computers') {
								$FilteredGroups += $Source
							}
						}
					
					#endregion Get Source Group
					
					#region Add to New Group
						
						If ($FilteredGroups -notcontains $TargetGroup) {
							Add-WSUSClientToGroup -ComputerName $ComputerName -Group $TargetGroup | Out-Null
							[Boolean]$AddedToNewGroup = $true
						}
						Else {
							[Boolean]$Success = $true
							[Boolean]$AddedToNewGroup = $false
							[string]$OldGroup = 'N/A'
							[string]$ScriptErrors = 'Already in Group'
						}
					
					#endregion Add to New Group
					
					#region Remove from Old Group
					
						If (($AddedToNewGroup -eq $true) -and ($FilteredGroups.Count -gt 0)) {
							[string]$OldGroup = $FilteredGroups | Select-Object -First 1
#							[string]$OldGroup = $FilteredGroups[0]
							Remove-WSUSClientFromGroup -Computer $ComputerName -Group $OldGroup | Out-Null
						}
					
					#endregion Remove from Old Group

					}

					#region Determine Success
					
						If ($ComputerFound -eq $true) {
#							If ($AddedToNewGroup -eq $true) {
								[array]$SourceGroups = Get-WSUSClient -Computer $ComputerName | Select-Object -ExpandProperty ComputerGroup
								[Boolean]$Success = $false
								Foreach ($Source in $SourceGroups) {
									If ($Source -match $TargetGroup) {
										[Boolean]$Success = $true
									}
								}
								If ($Success -eq $false) {
									[string]$ScriptErrors = 'Current Groups Do not match Target Group'
								}
								
#							}
#							Else {
#								[Boolean]$Success = $false
#								[string]$ScriptErrors = 'Failed to Add To New Group'
#							}
						}
						Else {
							[Boolean]$Success = $false
							[string]$ScriptErrors = 'Computer Not Found'
						}
					
					#endregion Determine Success
					
					#region Gather Client Information

						If ($ComputerFound -eq $true) {
							$WSUSClient = Get-WSUSClient -Computer $ComputerName
							If ($WSUSClient.FullDomainName) {
								[array]$FQDN = $WSUSClient.FullDomainName.Split('.')
								[string]$ComputerDomain = $FQDN[1] + "." + $FQDN[2] + "." + $FQDN[3]
								[string]$ComputerDomain = $ComputerDomain.ToUpper()
							}
							[string]$HostIP = $WSUSClient.IPAddress.IPAddressToString
							If ($WSUSClient.OSDescription) {
								[string]$OSVersion = $WSUSClient.OSDescription.Replace(",",'')
							}
							If ($WSUSClient.Make) {
								[string]$Make = $WSUSClient.Make.Replace(",",'')
							}
							If ($WSUSClient.Model) {
								[string]$Model = $WSUSClient.Model.Replace(",",'')
							}
							[string]$ClientVersion = $WSUSClient.ClientVersion
							[string]$LastSyncTime = $WSUSClient.LastSyncTime
						}
						Else {
							[string]$ComputerDomain = 'Unknown'
							[string]$HostIP = 'Unknown'
							[string]$OSVersion = 'Unknown'
							[string]$Make = 'Unknown'
							[string]$Model = 'Unknown'
							[string]$ClientVersion = 'Unknown'
							[string]$LastSyncTime = 'Unknown'
						}
				
					#endregion Gather Client Information
							
					#region Set Results if Missing
					
						If (!$ScriptErrors) {
							[string]$ScriptErrors = 'None'
						}
						If (!$ComputerDomain) {
							[string]$ComputerDomain = 'Unknown'
						}
						If (!$HostIP) {
							[string]$HostIP = 'Unknown'
						}
						If (!$OSVersion) {
							[string]$OSVersion = 'Unknown'
						}							
						If (!$Make) {
							[string]$Make = 'Unknown'
						}
						If (!$Model) {
							[string]$Model = 'Unknown'
						}
						If (!$ClientVersion) {
							[string]$ClientVersion = 'Unknown'
						}
						If (!$LastSyncTime) {
							[string]$LastSyncTime = 'Unknown'
						}
					
					#endregion Set Results if Missing
							
					#region Results
							
						$TaskResults = New-Object -TypeName PSObject -Property @{
							Hostname = $ComputerName
							Success = $Success
							OldGroup = $OldGroup
							NewGroup = $TargetGroup
							Domain = $ComputerDomain
							IP = $HostIP
							OS = $OSVersion
							Make = $Make
							Model = $Model
							ClientVersion = $ClientVersion
							LastSyncTime = $LastSyncTime
							Errors = $ScriptErrors
							ScriptVersion = $ScriptVersion
							AdminHost = $ScriptHost
							User = $UserName
						}
						$Results += $TaskResults
								
					#endregion Results
						
					# PROGRESS COUNTER
					$i++
				} #/Foreach Group
				Write-Progress -Activity "STARTING WSUS CLIENT LOOKUP" -Status "COMPLETED" -Completed 
			
			#endregion Loop
		}
	
	#endregion Main Tasks

#endregion Tasks

#region Write Results to CSV

	# SET DISPLAY ORDER FOR HEADER
	[array]$Header = @(
		"Hostname",
		"Success",
		"OldGroup",
		"NewGroup",
		"Domain",
		"IP",
		"OS",
		"Make",
		"Model",
		"ClientVersion",
		"LastSyncTime",
		"Errors",
		"ScriptVersion",
		"AdminHost",
		"User"
	)
	$Results | Select-Object $Header | Sort-Object -Property Group,Hostname | Export-Csv -Path $ResultsCSVFullName -NoTypeInformation -Force

#endregion Write Results to CSV

#region Script Completion Updates

	Show-ScriptHeader -BlankLines '1' -DashCount $DashCount -ScriptTitle $ScriptTitle
	Get-Runtime -StartTime $ScriptStartTime
	Show-ScriptStatusRuntimeTotals -StartTimeF $ScriptStartTimeF -EndTimeF $Global:GetRuntime.EndTimeF -Runtime $Global:GetRuntime.Runtime
	Write-Host ''
	Write-Host 'NEW GROUP:    ' -ForegroundColor Green -NoNewline
	Write-Host $TargetGroup
	Write-Host 'TOTAL CLIENTS:   ' -ForegroundColor Green -NoNewline
	Write-Host $TotalHosts
	Write-Host ''
	Write-Host 'Results Path:     '  -ForegroundColor Green -NoNewline
	Write-Host "$ResultsPath"
	Write-Host 'Results FileName: '  -ForegroundColor Green -NoNewline
	Write-Host "$ResultsCSVFileName"
	
	Show-ScriptStatusCompleted
	Set-WinTitleCompleted -WinTitleInput $Global:WinTitleInput

#endregion Script Completion Updates

#region Display Report
	
	If ($SkipOutGrid.IsPresent -eq $false) {
		$Results | Select-Object $Header | Sort-Object -Property Group,Hostname | Out-GridView -Title "Move WSUS Clients to Group Results for $InputItem"
	}
	
#endregion Display Report

#region Cleanup UI

	Reset-WindowsPatchingUI -StartingWindowTitle $StartingWindowTitle -StartupVariables $StartupVariables
	
#endregion Cleanup UI

}

#region Notes

<# Dependents
#>

<# Dependencies
	Get-Runtime
	Get-TimeZone
	Reset-WindowsPatchingUI
	Show-ScriptHeader
	Set-WinTitle
	Show-ScriptStatus
#>

<# TO DO
#>

<# Change Log
1.0.0 - 01/04/2013
	Created.
1.0.1 - 01/09/2013
	Cleaned up Dep check section
1.0.2 - 01/14/2013
	Renamed WPM to WindowsPatching
1.0.3 - 01/18/2013
	Renamed HostInputDesc to InputDesc
1.0.4 - 01/18/2013
	Added condition and error handling if computer in list does not
	exist on WSUS server.
#>


#endregion Notes
