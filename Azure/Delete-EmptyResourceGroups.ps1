$Conn = Get-AutomationConnection -Name AzureRunAsConnection
$Cred = Get-AutomationPSCredential -Name 'Service-ResourceManager'

Login-AzureRmAccount -Credential $Cred

$groups = Get-AzureRmResourceGroup
$total = 0
$numDeleted = 0

ForEach ($group in $groups) {
    $total += 1
    $name = $group.ResourceGroupName
    #$resources = Get-AzureRmResource -ResourceGroupName $name          -ResourceGroupName parameter doesn't work in Azure Automation
    $resources = Get-AzureRmResource | Where-Object { $_.ResourceGroupName -eq $name }
    if ($resources.Count -eq 0) {
        # Uncomment for testing 
        #$confirm = Read-Host "Resource Group $name is empty. Do you want to delete it? (y/n)"
        #if ($confirm.ToLower() -eq 'y') {
        Remove-AzureRmResourceGroup -Name $name -Force
        $numDeleted += 1
        Write-Output "Deleted resource group $name."
        #} else {
        #    Write-Output "Skipping resource group $name"
        #}
    }
    else {
        Write-Output "Resource group $name is NOT empty, skipping..."
    }
}

Write-Output "Deleted $numDeleted out of $total resource groups"