function Get-WSUSSubscription {
    <#  
    .SYNOPSIS  
        Displays WSUS subscription information.
        
    .DESCRIPTION
        Displays WSUS subscription information. You can view the next synchronization time, who last modified the schedule, etc...
        
    .NOTES  
        Name: Get-WSUSSubscription
        Author: Boe Prox
        DateCreated: 24SEPT2010 
               
    .LINK  
        https://learn-powershell.net
        
    .EXAMPLE  
    Get-WSUSSubscription      

    Description
    -----------  
    This command will list out the various subscription information on the WSUS server.
    #> 
    [cmdletbinding()]  
    Param () 
    Process {
        $wsus.GetSubscription()     
    }
} 