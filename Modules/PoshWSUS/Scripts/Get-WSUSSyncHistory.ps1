function Get-WSUSSyncHistory {
    <#  
    .SYNOPSIS  
        Retrieves the synchronization history of the WSUS server.
    .DESCRIPTION
        Retrieves the synchronization history of the WSUS server.    
    .NOTES  
        Name: Get-WSUSSyncHistory 
        Author: Boe Prox
        DateCreated: 24SEPT2010 
               
    .LINK  
        https://learn-powershell.net
    .EXAMPLE
    Get-WSUSSyncHistory

    Description
    -----------
    This command will list out the entire synchronization history of the WSUS server.  
           
    #> 
    [cmdletbinding()]  
    Param () 
    Begin {
        $sub = $wsus.GetSubscription()
    }
    Process {
        $sub.GetSynchronizationHistory()      
    }
} 