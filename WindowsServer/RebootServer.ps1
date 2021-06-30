<# 
This script does the following:
- Checks all registries to see if a reboot is required.
- Reboots the server if reboot required.
- Creates a log file in share of choice.

This scrip requires a method of deployment. 
#>

$Month = Get-Date -Format MM_yyyy
#$Date = Get-Date -Format MM_dd_yyyy
$LogFileName = "RebootLog_$Month.txt"
$LogFilePath = "SomeNetworkShare"
$HostName = "$env:COMPUTERNAME.$env:USERDNSDOMAIN"
Function Test-PendingReboot {
    If (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { Return $true }
    If (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { Return $true }
    If (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { Return $true }
    Try { 
        $Util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
        $Status = $Util.DetermineIfRebootPending()
        If (($Status -ne $null) -and $Status.RebootPending) {
            Return $true
        }
    }
    Catch { }

    Return $false
}

If (Test-PendingReboot -eq 'True') {

    "$HostName was rebooted" | Out-File "$LogFilePath\$LogFileName" -Append

}

Else {

    "$HostName was not rebooted" | Out-File "$LogFilePath\$LogFileName" -Append

} 