$response = @{}

function Onkyo-Discover {
    $udpClient = New-Object System.Net.Sockets.UdpClient
    $udpClient.EnableBroadcast = $true
    $udpClient.Client.ReceiveTimeout = 1000 # milliseconds
    $localEP = New-Object Net.IPEndPoint($([Net.IPAddress]::Any, 0))
    $remoteEP = New-Object Net.IPEndPoint($([Net.IPAddress]::Any, 0))
    $udpClient.Client.Bind($localEP)
    [byte[]]$packet = (73,83,67,80,0,0,0,16,0,0,0,11,1,0,0,0,33,120,69,67,78,81,83,84,78,13,10)
    $udpClient.Send($packet, $packet.Count, '255.255.255.255', 60128) | out-null
    $response = $udpClient.Receive([Ref]$remoteEP)
    # Get the command length. We need to convert to little-endian before conversion to Int32
    $cmdLength = [BitConverter]::ToInt32($response[11..8], 0)
    @{
        Name = [System.Text.Encoding]::ASCII.GetString($response[24..(13 + $cmdLength)]).split('/')[0];
        IPAddress = $remoteEP.Address.IPAddressToString;
        Port = $remoteEP.Port
    }
    $udpClient.Close()
}

function Onkyo-Connect ([string]$IPAddress, [uint32]$Port = 60128) {
    $script:socket = New-Object System.Net.Sockets.TcpClient
    $script:socket.ReceiveTimeout = 1000
    $script:socket.SendTimeout = 1000
    $script:socket.Connect($IPAddress, $Port)
}

function Onkyo-Disconnect {
    $script:socket.GetStream().Close()
    $script:socket.Close()
}

function Onkyo-Send ([string[]]$commands) {
    if (!$script:socket.Connected) { throw 'Not Connected' }
    foreach ($command in $commands) {
        if ($command.length -lt 3) { continue }
        #write-host $command
        # If no parameter specified add QSTN to the command to query the value of the attribute
        if ($command.Length -eq 3) { $command += 'QSTN' }

        $cmd = [System.Text.Encoding]::ASCII.GetBytes($command.toUpper()) #Protocol requires all CAPS
        $cmdLength = [BitConverter]::GetBytes($cmd.Length + 4) # The +4 is for !1 at the begining and CR+LF at end of all commands
        [Array]::Reverse($cmdLength) # Make it Big-endian
        [byte[]]$packet = (73,83,67,80,0,0,0,16) + $cmdLength + (1,0,0,0,33,49) + $cmd + (13,10)
        $stream = $script:socket.GetStream()
        $stream.Write($packet, 0, $packet.Length)
    }
    # Write any buffered data
    $stream.Flush()
}

function Onkyo-Get {
    if (!$script:socket.Connected) { throw 'Not connected' }
    $stream = $script:socket.GetStream()
    while ($stream.DataAvailable) {
        # Read the header and determine length of command

        [byte[]]$header = @()
        for ($i = 0; $i -lt 16; $i++) {
            try { $header += $stream.ReadByte() } catch { throw 'Response timed out' }
        }
    
        # Get the command length. We need to reverse to little-endian before conversion to Int32
        $cmdLength = [BitConverter]::ToInt32($header[11..8], 0)
    
        # Now read the command
        [byte[]]$cmd = @()
        for ($i = 0; $i -lt $cmdLength; $i++) {
            try { $cmd += $stream.ReadByte() } catch { throw 'Error reading response' }
        }

        # Strip first two and last two bytes, convert to ASCII and store
        $responseStr = [System.Text.Encoding]::ASCII.GetString($cmd[2..($cmd.Length - 4)])
        $response[$responseStr.Substring(0,3)] = $responseStr.Substring(3)
    }
    $response
}
