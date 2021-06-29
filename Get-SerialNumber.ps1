#Invoke an inline command on the remote machine to its log serial number to a txt file.

#WinRM credentials
$Credential = Get-Credential

#List of servers, either csv, txt, or manual.
$Computers = Get-Content -Path "somepath\somedir\somefile.txt"

#Accessible share for output.
$FilePath = "\\someshare\somedir"
$FileName = "somename.txt"

Foreach ($Computer in $Computers) {

    $SerialNumber = Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { wmic bios get serialnumber } 

    #Log serialnumber to output file.
    $Computer | Out-File "$FilePath\$FileName" -Append
    $SerialNumber | Out-File "$FilePath\$FileName" -Append

}