# Configure the serial port
$port = New-Object System.IO.Ports.SerialPort COM37, 38400, None, 8, 1
$port.Open()


function Send-SerialData {
    param (
        [Parameter(Mandatory=$true)]
        [string]$data,
        [Parameter(Mandatory=$true)]
        [System.IO.Ports.SerialPort]$port
    )
    $port.WriteLine($data)
    $port.WriteLine("`r")
}



function OperationMode {
    param (
        [Parameter(Mandatory=$true)]
        [System.IO.Ports.SerialPort]$port
    )
	Write-Host("Please select Operation Mode")
	Write-Host("0: Capacitive")
	Write-Host("1: Conductive")

    while ($true) {
		$port.DiscardInBuffer()
        $operationmode = Read-Host "Operation Mode selected"
        Send-SerialData -data $operationmode -port $port
        Start-Sleep -Milliseconds 10

        if ($port.BytesToRead -gt 0) {
            $response = $port.ReadByte()
            if ($response -eq 6) {
                break
            }
            elseif ($response -eq 21) {
                Write-Host "Wrong Operation Mode. Please select another option!"
            }
            else {
                Write-Host "Unknown response: $response, please try again."
            }
        }
        else {
            Write-Host "No response from device, please try again."
        }
    }
	Write-Host("`n`r")
}


function SleepTime {
    param (
        [Parameter(Mandatory=$true)]
        [System.IO.Ports.SerialPort]$port
    )
	Write-Host("Please select Sleep Time")
	Write-Host("0: Wake-up on request")
	Write-Host("1: 1 second")
	Write-Host("2: 2 seconds")
	Write-Host("3: 4 seconds")
	Write-Host("4: 8 seconds")
	Write-Host("5: 16 seconds")
	Write-Host("6: 32 seconds")
	Write-Host("7: 64 seconds")
	Write-Host("8: 128 seconds")
	Write-Host("9: 256 seconds")

    while ($true) {
		$port.DiscardInBuffer()
        $sleep = Read-Host("Sleep Time selected ")
        Send-SerialData -data $sleep -port $port
        Start-Sleep -Milliseconds 10

        if ($port.BytesToRead -gt 0) {
            $response = $port.ReadByte()
            if ($response -eq 6) {
                break
            }
            elseif ($response -eq 21) {
                Write-Host "Wrong Sleep Time. Please select another option!"
            }
            else {
                Write-Host "Unknown response: $response, please try again."
            }
        }
        else {
            Write-Host "No response from device, please try again."
        }
    }
	Write-Host("`n`r")
}


function ExtendedOutputMode {
    param (
        [Parameter(Mandatory=$true)]
        [System.IO.Ports.SerialPort]$port
    )
	Write-Host("Please select UART configuration")
	Write-Host("0: UART Disabled")
	Write-Host("1: UART Enabled")

    while ($true) {
		$port.DiscardInBuffer()
        $global:uartmode = Read-Host("UART configuration selected ")
        Send-SerialData -data $global:uartmode -port $port
        Start-Sleep -Milliseconds 10

        if ($port.BytesToRead -gt 0) {
            $response = $port.ReadByte()
            if ($response -eq 6) {
                break
            }
            elseif ($response -eq 21) {
                Write-Host "Wrong UART configuration. Please select another option!"
            }
            else {
                Write-Host "Unknown response: $response, please try again."
            }
        }
        else {
            Write-Host "No response from device, please try again."
        }
    }
	Write-Host("`n`r")
}


function ExtendedOutputFormat {
    param (
        [Parameter(Mandatory=$true)]
        [System.IO.Ports.SerialPort]$port
    )
	Write-Host("Please select Extended Output Format")
	Write-Host("0: Delta measurement")
	Write-Host("1: Standard measurement")
	Write-Host("2: Both standard and delta measurements")
	Write-Host("3: Data Streamer protocol format")

    while ($true) {
		$port.DiscardInBuffer()
        $global:outformat = Read-Host("Extended Output Format selected ")
        Send-SerialData -data $global:outformat -port $port
        Start-Sleep -Milliseconds 10

        if ($port.BytesToRead -gt 0) {
            $response = $port.ReadByte()
            if ($response -eq 6) {
                break
            }
            elseif ($response -eq 21) {
                Write-Host "Wrong Extended Output Format. Please select another option!"
            }
            else {
                Write-Host "Unknown response: $response, please try again."
            }
        }
        else {
            Write-Host "No response from device, please try again."
        }
    }
	Write-Host("`n`r")
}

function ReferenceValue {
    param (
        [Parameter(Mandatory=$true)]
        [System.IO.Ports.SerialPort]$port
    )

    # Read the current reference value from the device
    do {
        $global:baseline = $port.ReadLine().Trim()
    } while ($global:baseline -notmatch '^(\d+)$')
    Write-Host "Current Reference Value: $global:baseline"

    do {
        Write-Host "Please select Reference Value Option"
        Write-Host "0: Set the standard measurement as Reference Value"
        Write-Host "1: Repeat the measurement"
        Write-Host "2: Set custom Reference Value"

        $optionValid = $false
        while (-not $optionValid) {
            $port.DiscardInBuffer()
            Write-Host("`n`r")
            $referencevalue = Read-Host "Reference Value Option selected"
            Send-SerialData -data $referencevalue -port $port
            Write-Host("`n`r")

            Start-Sleep -Milliseconds 10

            if ($port.BytesToRead -gt 0) {
                $response = $port.ReadByte()
                if ($response -eq 6) {
                    $optionValid = $true
                }
                elseif ($response -eq 21) {
                    Write-Host "Wrong Reference Value Option. Please select another option!"
                }
                else {
                    Write-Host "Unknown response: $response, please try again."
                }
            }
            else {
                Write-Host "No response from device, please try again."
            }
        }

        if ($referencevalue -eq 0) {
            # Option 0: Set current measurement as reference
            Write-Host "Reference Value set: $global:baseline"
            break
        }
        elseif ($referencevalue -eq 2) {
            # Option 2: Set custom reference value
            Write-Host("Please set custom Reference Value (0-65535)")
            while ($true) {
                $port.DiscardInBuffer()
                $customreference = Read-Host("Custom Reference Value set: ")
                Send-SerialData -data $customreference -port $port
                Start-Sleep -Milliseconds 10

                if ($port.BytesToRead -gt 0) {
                    $response = $port.ReadByte()
                    if ($response -eq 6) {
                        break
                    }
                    elseif ($response -eq 21) {
                        Write-Host "Invalid custom Reference Value value. Please set a valid value!"
                    }
                    else {
                        Write-Host "Unknown response: $response, please try again."
                    }
                }
                else {
                    Write-Host "No response from device, please try again."
                }
            }
            break
        }
        elseif ($referencevalue -eq 1) {
            # Option 1: Repeat the measurement
            do {
                $repeatvalue = $port.ReadLine().Trim()
            } while ($repeatvalue -notmatch '^(\d+)$')
            Write-Host "Repeated Reference Value: $repeatvalue"
            $global:baseline = $repeatvalue
        }
        else {
            Write-Host "Invalid option, please try again."
        }

    } while ($referencevalue -ne 0)
    Write-Host("`n`r")
}


function DetectionThreshold {
    param (
        [Parameter(Mandatory=$true)]
        [System.IO.Ports.SerialPort]$port
    )
	Write-Host("Please set custom Detection Threshold (0-65535)")
    while ($true) {
		$port.DiscardInBuffer()
        $threshold = Read-Host("Detection Threshold set: ")
        Send-SerialData -data $threshold -port $port
        Start-Sleep -Milliseconds 10

        if ($port.BytesToRead -gt 0) {
            $response = $port.ReadByte()
            if ($response -eq 6) {
                break
            }
            elseif ($response -eq 21) {
                Write-Host "Invalid Detection Threshold value. Please set a valid value!"
            }
            else {
                Write-Host "Unknown response: $response, please try again."
            }
        }
        else {
            Write-Host "No response from device, please try again."
        }
    }
	Write-Host("`n`r")
}


$version = "1.0.0"
Write-Host "MTCH9010 Enhanced Configuration Script version $version"
Write-Host "Waiting for reset. Please apply a reset!"
Write-Host("`n`r")
do {
    $data = $port.ReadLine().Trim()
} while ($data -ne "Firmware v1.2.1")

Write-Host "Reset received!"
Write-Host "$data"
Write-Host("`n`r")

$port.DiscardInBuffer()

OperationMode -port $port
SleepTime -port $port
ExtendedOutputMode -port $port
if ($global:uartmode -eq 1){
	ExtendedOutputFormat -port $port
}
ReferenceValue -port $port
DetectionThreshold -port $port

if($global:outformat -ne 3) {
    Write-Host "Configuration Done! Press any key to exit."
    $port.DiscardInBuffer()
    do {
        if ($port.BytesToRead -gt 0) {
            $data = $port.ReadLine().Trim()
            Write-Host "$data"
        }
        # Exit loop if any key is pressed
        if ([System.Console]::KeyAvailable) {
            Write-Host "Key pressed. Exit..."
            [void][System.Console]::ReadKey($true)
            break
        }
        Start-Sleep -Milliseconds 50
    } while ($true)
}
else {
    Write-Host "Configuration Done! Press any key to exit."
    do {
        if ([System.Console]::KeyAvailable) {
                Write-Host "Key pressed. Exit..."
                [void][System.Console]::ReadKey($true)
                break
            }
    }while($true)
}

$port.Close()
