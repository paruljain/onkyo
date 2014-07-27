SYNOPSIS
--------
Remote control for Onkyo network home theatre receivers

DESCRIPTION
-----------
Script module to discover Onkyo network connected home theatre receiver and then send remote control commands to change settings such as volume and also query current settings. Uses the Integra Serial Communication Protocol (ISCP). Tested with Onkyo TX-NR509. As of now this can only work with one receiver at a time however extending to multiple receivers should not be that hard. Please contact the author if you have need for multiple receivers or any other requirements.

Complete Integra Serial Communication Protocol is documented here: http://blog.siewert.net/files/ISCP%20AV%20Receiver%20v124-1.xls

Combine this module with a simple PowerShell RESTful server http://poshcode.org/4073 and some HTML/Javascript and you can quickly build a nice HTML interface to your Onkyo receiver that can be used from any device including PC, Mac and mobile devices. Very useful when you want advanced commands such as dynamic range control that are not available in the official app.

EXAMPLE 1
---------
    Import-Module .\onkyo.psm1
    Onkyo-Discover

EXAMPLE 2
---------
    Import-Module .\onkyo.psm1
    Onkyo-Connect 192.168.1.200
    Onkyo-Send 'pwr01','mvl20', 'sli24', 'tun10670'
    Start-Sleep 10
    Onkyo-Get
    Onkyo-Disconnect
