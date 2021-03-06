function Get-WSUSContentDownloadProgress {
    <#  
    .SYNOPSIS  
        Retrieves the progress of currently downloading updates. Displayed in bytes downloaded.
        
    .DESCRIPTION
        Retrieves the progress of currently downloading updates. Displayed in bytes downloaded.
   
    .NOTES  
        Name: Get-WSUSContentDownloadProgress
        Author: Boe Prox
        DateCreated: 24SEPT2010 
               
    .LINK  
        https://learn-powershell.net
        
    .EXAMPLE  
    Get-WSUSContentDownloadProgress

    Description
    ----------- 
    This command will display the current progress of the content download.
           
    #> 
    [cmdletbinding()]  
    Param ()
    Process {
        #Gather all child servers in WSUS    
        $wsus.GetContentDownloadProgress()       
    }
}