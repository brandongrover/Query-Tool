#############################################################################
############################  Global Variables  #############################
#############################################################################
#Modify path
$path = Get-Location
$date = Get-Date -Format yyyyMMdd
$queryData = Get-Content $path\QueryList.txt
$infoIP = 0
$infoName = 0
$infoStatus = 0
$infoResponseTime = 0
$counter = 0
#############################################################################
#################################  Header  ##################################
#############################################################################
$item = "*"
Write-Host $item.padright(99,'*')
Write-Host $item.padright(40,"*")" Asset Query Tool "$item.padright(39,"*")
Write-Host $item.padright(99,'*')
#############################################################################
############################  Setup and Checks  #############################
#############################################################################
if(Test-Path $path\QueryList.txt) {
    Write-Host "Query List found."
} else {
    Write-Host "Please add QueryList.txt to the same directory as this script."
}
$queryName = Read-Host -Prompt "What would you like to name this Query?"
    Write-Host "Acknowledged:  $queryName"
#Set Output object
$resultsOutput = "$path\$queryName-Results-$date.csv" # Set output name
#Remove old object check
if (Test-Path $resultsOutput) {
    Write-Warning -Message "$resultsOutput already exists."
    
    $reply = Read-Host -Prompt "Default behaviour will append to it. Would you like to delete it instead? [y/n]"
        if ( $reply -match "[yY]" ) {
            Remove-Item $resultsOutput
            Write-Host "$resultsOutput deleted. Continuing..."
        }
}

$reply = Read-Host -Prompt "Would you like to grab IP? [y/n]"
    Write-Host ""
        if ( $reply -match "[yY]" ) {
            $infoIP = 1
        } 
$reply = Read-Host -Prompt "Would you like to grab DNS Name? [y/n]"
    Write-Host ""
        if ( $reply -match "[yY]" ) {
            $infoName = 1
        }
$reply = Read-Host -Prompt "Would you like to grab device state (UP/DOWN)? [y/n]"
    Write-Host ""
        if ( $reply -match "[yY]" ) {
            $infoStatus = 1
        }
$reply = Read-Host -Prompt "Would you like to grab connection attempt response time? [y/n]"
    Write-Host ""
        if ( $reply -match "[yY]" ) {
            $infoResponseTime = 1
        }
Write-Host $item.padright(99,'*')
Write-Host $item.padright(40,"*")" Beginning Query "$item.padright(40,"*")
Write-Host $item.padright(99,'*')

#############################################################################
####################  Ping Query List and Output Results  ###################
#############################################################################
#Begin pinging and output
$queryData | where-Object {$_ -ne ''} | ForEach({
    #data check
    if($_ -match "[a-z]"){
        $infoName1 = 0
        $name = $_
    } else {
        $infoName1 = $infoName
    }
    #loop vars
    $counter = $counter + 1
    $queryMax = $queryData.Length
    #Get Status
    
    $pingResult = Test-Connection "$_" -Count 1 -EA SilentlyContinue 
    if ($pingResult) {
        $status = "UP"
    } else {
        $status = "DOWN"
    }
   

    #DNS Name
    if($infoName1) {
        try {
            $name = Resolve-DnsName -Name $_ -DnsOnly -EA Stop | Select -First 1 -ExpandProperty NameHost -EA Stop
        } catch {
            Write-Warning -Message “DNS Record not found for $_”
            $name = $null
        }
    }
    #Set output properties - Currently Disabled
    #$outputProperties = @()
    #if($infoIP) {
    #    $outputProperties = $outputProperties + "IP"
    #}
    #if($infoName) {
    #    $outputProperties = $outputProperties + "Name"
    #}
    #if($infoStatus) {
    #    $outputProperties = $outputProperties + "Status"
    #}
    #if($infoResponseTime) {
    #    $outputProperties = $outputProperties + "Response Time"
    #}
    #IP/Name Fix
    if($pingResult.IPV4Address) {
        $IP = $pingResult.IPV4Address
    } else {
        $IP = $null
    }
    if($_ -match "[a-z]") {
    } else {
        if($pingResult){
        } else {
            $IP = $_
        }
    }

    #Output
    New-Object PSobject -Property @{
    "Status" = $status
    "Name" = $name
    "IP" = $IP
    "Response Time" = $pingresult.ResponseTime

    } | Select-Object -Property "Name", "IP", "Status", "Response Time"
    Write-Host "[$counter/$queryMax] Finished $_ "
}) | Where-Object {$_ -ne $null} | Export-Csv -Delimiter ',' -Path $resultsOutput -NoTypeInformation -Append
Write-Host $item.padright(99,'*')
Write-Host "Completed task. Press any key to exit."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');