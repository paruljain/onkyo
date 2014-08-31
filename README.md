Onkyo Remote Control
--------------------
Script module to discover Onkyo network connected home theatre receiver and then send remote control commands to change settings such as volume. Can also query current settings. Changes made from other remotes or by using the control panel of the receiver are also conveyed in real time as PowerShell Events.

Uses the Integra Serial Communication Protocol (ISCP). Tested with Onkyo TX-NR509. As of now this can only work with one receiver at a time however extending to multiple receivers should not be that hard.

Complete Integra Serial Communication Protocol is documented here: http://blog.siewert.net/files/ISCP%20AV%20Receiver%20v124-1.xls

EXAMPLE
-------
    $onkyo = Import-Module .\onkyo.psm1 -AsCustomObject -Force
    $onkyo.Discover()
    $onkyo.Connect()
    if (!$onkyo.IsConnected) { throw 'Unable to connect to receiver' }
    
    Register-EngineEvent -SourceIdentifier OnkyoMessage -Action { Write-Host ('Receiver sent: ' + $args[0]) }
    
    $onkyo.Send(('pwr01','mvl20', 'sli24', 'tun10670'))
    
    # Wait for commands to run on receiver
    Start-Sleep -Seconds 5
    
    # You can also access lastest value of any control through the Received hashtable
    # as an alternative to Register-EngineEvent above
    'Current master volume in hexadecimal is: ' + $onkyo.Received['MVL']
    
    # Ask receiver the currently tuned radio frequency
    $onkyo.Send('tun')
