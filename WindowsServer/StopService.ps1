#WinRM credentials
$Credential = Get-Credential
$ServiceName = "SomeService"
#List of servers, either csv, txt, or manual.
$Computers = Get-Content -Path "somepath\somedir\somefile.txt"

Foreach ($Computer in $Computers) {

    $Service = Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { Get-Service -Name $ServiceName }

    Switch ($Service.Status) {

        'Running' {  
            Write-Host "Stopping $ServiceName on $Computer..."
            Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { Stop-Service -Name $ServiceName -Force }
            Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { Set-Service -Name $ServiceName -StartupType Disabled }
        }

        'Stopped' { Write-Host "$ServiceName is not currently running on $Computer." }

    }
    
}