function Get-WSUSServer {
    <#  
    .SYNOPSIS  
        Retrieves connection and configuration information from the WSUS server.
        
    .DESCRIPTION
        Retrieves connection and configuration information from the WSUS server. 
        
    .PARAMETER ShowConfiguration
        Lists more configuration information from WSUS Server     
         
    .NOTES  
        Name: Get-WSUSServer
        Author: Boe Prox
        DateCreated: 24SEPT2010 
               
    .LINK  
        https://learn-powershell.net
        
    .EXAMPLE
    Get-WSUSServer

    Description
    -----------
    This command will display basic information regarding the WSUS server.
    .EXAMPLE
    Get-WSUSServer -ShowConfiguration      

    Description
    -----------
    This command will list out more detailed information regarding the configuration of the WSUS server.
           
    #> 
    [cmdletbinding()]
        Param(                         
            [Parameter(
                Position = 0,
                ValueFromPipeline = $False)]
                [switch]$ShowConfiguration                     
                )                    
    Process {                
        If ($PSBoundParameters['ShowConfiguration']) {
            $wsus.GetConfiguration()
        } Else {
            $wsus
        }  
    }      
}