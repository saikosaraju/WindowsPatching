Function New-WSUSComputerScope {
    <#  
    .SYNOPSIS  
        Creates a new computer scope object        
        
    .DESCRIPTION        
        Creates a new computer scope object
        
    .PARAMETER NameIncludes        
        Sets a name to search for. 
        
    .PARAMETER IncludedInstallationState        
        Sets the update installation states to search for.
        Accepted values are: "Any","Declined","HasStaleUpdateApprovals","LatestRevisionApproved","NotApproved"
        
    .PARAMETER ExcludedInstallationState         
        Sets the installation states to exclude. 
        Accepted values are: "Any","Declined","HasStaleUpdateApprovals","LatestRevisionApproved","NotApproved"
    
    .PARAMETER IncludeSubGroups
        Sets whether the ComputerTargetGroups property should include descendant groups.
        
    .PARAMETER IncludeDownstreamComputerTargets
        Sets whether or not clients of a downstream server, not clients of this server, should be included.
    
    .PARAMETER OSFamily
        Sets the operating system family for which to search.
    
    .PARAMETER FromLastSyncTime
        Sets the earliest last synchronization time to search for. 
    
    .PARAMETER ToLastSyncTime
        Sets the latest last synchronization time to search for. 
    
    .PARAMETER FromLastReportedStatusTime
        Sets the earliest reported status time. 
    
    .PARAMETER ToLastReportedStatusTime
        Sets the latest last reported status time to search for.
               
    .NOTES  
        Name: New-WSUSComputerScope
        Author: Boe Prox
        DateCreated: 24SEPT2011 
               
    .LINK  
        https://learn-powershell.net
        
    .EXAMPLE 
   
    #> 
    [cmdletbinding()]
    Param (
        [parameter()]
        [string]$NameIncludes,        
        [parameter()]
        [Microsoft.UpdateServices.Administration.UpdateInstallationStates]$IncludedInstallationState,
        [parameter()]
        [Microsoft.UpdateServices.Administration.UpdateInstallationStates]$ExcludedInstallationState,
        [parameter()]
        [bool]$IncludeSubGroups,
        [parameter()]
        [bool]$IncludeDownstreamComputerTargets,
        [parameter()]
        [string[]]$OSFamily,
        [parameter()]
        [datetime]$FromLastSyncTime, 
        [parameter()]
        [datetime]$ToLastSyncTime,   
        [parameter()]
        [datetime]$FromLastReportedStatusTime,   
        [parameter()]
        [datetime]$ToLastReportedStatusTime
        )
    Begin {
        Write-Verbose "Creating Computer Scope Object"
        $computerscope = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
    }
    Process{
        If ($PSBoundParameters['NameIncludes']) {
            Write-Verbose "Adding values to NameIncludes property"
            $computerscope.NameIncludes = $NameIncludes
        }       
        If ($PSBoundParameters['IncludedInstallationState']) {
            Write-Verbose "Adding values to IncludedInstallationState property"
            $computerscope.IncludedInstallationStates = $IncludedInstallationState
        }
        If ($PSBoundParameters['ExcludedInstallationState']) {
            Write-Verbose "Adding values to ExcludedInstallationState property"
            $computerscope.ExcludedInstallationStates = $ExcludedInstallationState
        }
        If ($PSBoundParameters['IncludeSubGroups']) {
            Write-Verbose "Adding values to IncludeSubGroups property"
            $computerscope.IncludeSubGroups = $True
        }
        If ($PSBoundParameters['IncludeDownstreamComputerTargets']) {
            Write-Verbose "Adding values to IncludeDownstreamComputerTargets property"
            $computerscope.IncludeDownstreamComputerTargets = $True
        }
        If ($PSBoundParameters['OSFamily']) {
            Write-Verbose "Adding values to OSFamily property"
            $computerscope.OSFamily = $OSFamily
        }
        If ($PSBoundParameters['FromLastSyncTime']) {
            Write-Verbose "Adding values to FromLastSyncTime property"
            $computerscope.FromLastSyncTime = $FromLastSyncTime
        }
        If ($PSBoundParameters['ToLastSyncTime']) {
            Write-Verbose "Adding values to ToLastSyncTime property"
            $computerscope.ToLastSyncTime = $ToLastSyncTime
        }
        If ($PSBoundParameters['FromLastReportedStatusTime']) {
            Write-Verbose "Adding values to FromLastReportedStatusTime property"
            $computerscope.FromLastReportedStatusTime = $FromLastReportedStatusTime
        }
        If ($PSBoundParameters['ToLastReportedStatusTime']) {
            Write-Verbose "Adding values to ToLastReportedStatusTime property"
            $computerscope.ToLastReportedStatusTime = $ToLastReportedStatusTime
        }
    }
    End {
        Write-Output $computerscope
    }
}