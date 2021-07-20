$Credential = Get-Credential 
$Computers = Get-Content -Path "Somedir\somelist.txt"
$LogFilePath = "\\Someshare\somedir"
$FileName = "Results.txt"


Foreach ($Computer in $Computers) {
    [string]$OSVersion = Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName }

    Switch ( $OSVersion ) {

        "Windows Server 2012 R2 Datacenter" { 
            
            #Windows Print Spooler Remote Code Execution Vulnerability Patches.
            $Result = Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { Get-Hotfix -Id KB5004954, KB5004958 -ErrorAction Ignore } 
            
            #Scripting Engine Memory Corruption Vulnerability Patches.
            $Result2 = Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { Get-Hotfix -Id KB5004298, KB50044233 -ErrorAction Ignore } 
        
        }
        
        "Windows Server 2016 Datacenter" { 
            
            #Windows Print Spooler Remote Code Execution Vulnerability Patches.
            $Result = Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { Get-Hotfix -Id KB5004948 -ErrorAction Ignore } 
        
            #Scripting Engine Memory Corruption Vulnerability Patches.
            $Result2 = Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { Get-Hotfix -Id KB5004238 -ErrorAction Ignore } 
        
        }

    }

    If (!($Result)) {

        $Computer | Out-File $LogFilePath\$FileName -Append

        Write-Output "Windows Print Spooler Remote Code Execution patch is not installed on $Computer." | Out-File $LogFilePath\$FileName -Append

    }
    
    Else {

        Write-Output "Windows Print Spooler Remote Execution patch is installed on $Computer. Confirmed updates below." | Out-File $LogFilePath\$FileName -Append
        $Result | Out-File $LogFilePath\$FileName -Append
        
    }
    
    
    If (!($Result2)) {

        $Computer | Out-File $LogFilePath\$FileName -Append

        Write-Output "Scripting Engine Memory Corruption Vulnerability patch is not installed on $Computer." | Out-File $LogFilePath\$FileName -Append

    }
    
    Else {

        Write-Output "Scripting Engine Memory Corruption Vulnerability patch is installed on $Computer. Confirmed updates below." | Out-File $LogFilePath\$FileName -Append
        $Result2 | Out-File $LogFilePath\$FileName -Append

    }

}