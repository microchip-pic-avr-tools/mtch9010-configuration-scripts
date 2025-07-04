# Configure the serial port
$port = New-Object System.IO.Ports.SerialPort COM37, 38400, None, 8, 1 

function Send-SerialData($data){
	$port.WriteLine($data)
	$port.WriteLine("`r")
	Start-Sleep -Milliseconds 500
}

# Configuration
$opmode = 1
$sleeptime = 3
$global:outputmode = 1
$outputformat = 2
$referencevalue = 0
$threshold = 800

$port.Open()
$version = "1.0.0"
Write-Host "MTCH9010 Basic Configuration Script version $version"
Write-Host "Waiting for reset. Please apply a reset!"

do {
	$data = $port.ReadLine().Trim()
}while ($data -ne "Firmware v1.2.1")

Write-Host "Reset received."
Write-Host "$data"
Write-Host("`n`r")

Write-Host "Sending configuration" 
Start-Sleep -Milliseconds 500

Write-Host "Operation Mode: $opmode"
Send-SerialData $opmode
Write-Host "Sleep Time: $sleeptime "
Send-SerialData $sleeptime
Write-Host "Extended Output Mode: $global:outputmode"
Send-SerialData $global:outputmode
if ($global:outputmode -eq 1){
	Write-Host "Extended Output Format: $outputformat"
	Send-SerialData $outputformat
}

do {
	$global:baseline = $port.ReadLine().Trim()

}while ($global:baseline -notmatch '^(\d+)$')

Write-Host "Reference Value: $global:baseline" 
Write-Host "Confirm Reference Value: $referencevalue" 
Send-SerialData $referencevalue
Write-Host "Detection Threshold: $threshold" 
Send-SerialData $threshold 
Write-Host("`n`r")
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

$port.Close()