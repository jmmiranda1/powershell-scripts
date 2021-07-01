#WinRM credentials
$Credential = Get-Credential

#List of servers, either csv, txt, or manual.
$Computers = Get-Content -Path "somepath\somedir\somefile.txt"

Foreach ($Computer in $Computers) {

    Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { Stop-Service -Name Spooler -Force }
    Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { Set-Service -Name Spooler -StartupType Disabled }

}