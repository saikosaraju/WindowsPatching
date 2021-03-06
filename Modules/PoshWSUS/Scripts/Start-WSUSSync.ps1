function Start-WSUSSync {
    <#  
    .SYNOPSIS  
        Start synchronization on WSUS server.
   
    .DESCRIPTION
        Start synchronization on WSUS server.
       
    .NOTES  
        Name: Start-WSUSSync
        Author: Boe Prox
        DateCreated: 24SEPT2010 
               
    .LINK  
        https://learn-powershell.net
        
    .EXAMPLE
    Start-WSUSSync

    Description
    -----------
    This command will begin a manual sychronization on WSUS with the defined update source.      
           
    #> 
    [cmdletbinding(
    	ConfirmImpact = 'low',
        SupportsShouldProcess = $True
    )] 
    Param ()
    Begin {
        $sub = $wsus.GetSubscription()    
        $sync = $sub.GetSynchronizationProgress()  
    }
    Process {  
        #Start WSUS synchronization
        If ($pscmdlet.ShouldProcess($($wsus.name))) {
            $sub.StartSynchronization()  
            "Synchronization has been started on {0}." -f $wsus.name
        } 
    }
} 