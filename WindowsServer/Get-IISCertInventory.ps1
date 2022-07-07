#This script will get a list of all IIS Bindings in Powershell

# credentials for servers.
$serverCredential = Get-Credential -Message "Enter your credentials for Prod.local"

# credentials for Azure
if (!(Get-AzSubscription -ErrorAction SilentlyContinue)) {
    $AzureCredential = Get-Credential -Message "Enter your credentials for Azure"

    # connect to Azure Account
    Connect-AzAccount
}


# Get Server List from azure
$servers = Get-Azvm | Select Name

# Asks for a valid path and tests it.
$path = Read-Host -Prompt "Please enter a path to export your file."
$validPath = "false"
while ($validPath -eq "false") {
    if (Test-Path -Path $path) {
        $validPath = "true"
        Write-Host "Valid path entered"
    }
    else {
        $path = Read-Host -Prompt "Enter a valid path"    
    }
}

# Checks if the path ends with \ and modify it accordingly.
if ($path -match '\\$') {
    $exportpath = $path + "CertificateInventory.txt"
}
else {
    $exportpath = $path + "\CertificateInventory.txt"
}



# Script block that will collect all the information required
# This script block can be run locally on a VM to get results for that VM only
# This also assumes the webAdministration Moudle is alraedy installed

$scriptBlock = {
    Import-Module -Name WebAdministration

    $iisSites = @()

    Get-ChildItem -Path IIS:SSLBindings | ForEach-Object -Process `
    {
        if ($_.Sites) {
            $certificate = Get-ChildItem -Path CERT:LocalMachine/My |
            Where-Object -Property Thumbprint -EQ -Value $_.Thumbprint
            $BindingList = New-Object System.Collections.Specialized.OrderedDictionary
            $BindingList.Add("Hostname", $env:COMPUTERNAME)     
            $BindingList.add("Sites", $_.Sites.Value)
            $BindingList.Add("Port", $_.port)
            $BindingList.add("CertificateFriendlyName", $certificate.FriendlyName)
            $BindingList.add("CertificateDnsNameList", $certificate.DnsNameList)
            $BindingList.add("CertificateExpiration", $certificate.NotAfter)
            $BindingList.add("CertificateIssuer", $certificate.Issuer)
            $BindingList.add(" ", " ")

            $iisSites = $iisSites + $BindingList
            
        }
    }

    return $iisSites
}

$finalResult = @()
$FQDNServerList = @()

# Attach the appropriate domain name to the severs based on it's name

foreach ($server in $servers) {
    if ($server.Name -match "SomeName") {
        $serverName = $server.Name + ".SomeDomain"
        $FQDNServerList = $FQDNServerList + $serverName
    }
    else {
        $serverName = $server.Name + ".AnotherDomain"
        $FQDNServerList = $FQDNServerList + $serverName
    }    
}


# Check each server if they have IIS installed and store in array
$IISservers = @()
foreach ($FQDNServer in $FQDNServerList) {
    if ($service = Get-Service -Name "IISAdmin" -ComputerName $FQDNServer -ErrorAction SilentlyContinue) {
        write-host $service.MachineName $service.DisplayName $service.Status
        $IISservers = $IISservers + $FQDNServer
    }
    else {
        write-host "IIS service is not running on " $FQDNServer
    }
    
    
}

# Inspect each server in IIS array for what certificates are installed
foreach ($IISserver in $IISservers) {
    $result = @()
    write-host "Scanning "$IISserver
    if ($IISserver -match "SomeDomain") {
        $result = Invoke-Command -ComputerName $IISserver -ScriptBlock $scriptBlock
        $finalResult = $finalResult + $result
    }
    else {
        $result = Invoke-Command -ComputerName $IISserver -ScriptBlock $scriptBlock -Credential $serverCredential
        $finalResult = $finalResult + $result
    }
    
}



$finalResult   | Out-File -FilePath $exportpath
