#This quick script removes peering between two given vnets so we can add new addresspaces and subnets. The peering is re-established again.

$Rg = "SomeResourceGroup"
$VnetName = "SomeVnet"

# Add new Address Spaces, add as many as required but update variables accordingly
$NewAddressSpace01 = "SomeIpRange"
$NewAddressSpace02 = "SomeIpRange"

# Add new subnets, not required if only adding more address spaces. Or comment out. 
$NewSubnet01 = "SomeIpRange"
$NewSubnet02 = "SomeIpRange"

$Vnet = Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $Rg
$Peer = Get-AzVirtualNetworkPeering -ResourceGroupName $Rg -VirtualNetworkName $VnetName

# Query peer info
$PeerVnetId = $Peer.RemoteVirtualNetwork.Id
$PeerVnetName = $PeerVnetId.Substring($PeerVnetId.LastIndexOf('/') + 1)
$PeerVnet = Get-AzVirtualNetwork -Name $PeerVnetName
$PeerRg = $PeerVnet.ResourceGroupName
$PeerPeeringName = $PeerVnet.VirtualNetworkPeerings.Where( { $_.RemoteVirtualNetwork.Id -like "*$($Vnet.Name)" }).Name

# Remove peer from given ResourceGroup
Remove-AzVirtualNetworkPeering -Name $Peer.Name -VirtualNetworkName $VnetName -ResourceGroupName $Rg

# Add new address space
$Vnet.AddressSpace.AddressPrefixes.Add($NewAddressSpace01)
$Vnet.AddressSpace.AddressPrefixes.Add($NewAddressSpace02)

# Add subnets, if configured. Or comment out. 
Add-AzVirtualNetworkSubnetConfig -Name "SomeSubnetName" -VirtualNetwork $Vnet -AddressPrefix $NewSubnet01 | Set-AzVirtualNetwork
Add-AzVirtualNetworkSubnetConfig -Name "SomeSubnetName" -VirtualNetwork $Vnet -AddressPrefix $NewSubnet02 | Set-AzVirtualNetwork

# Remove peer from Peer side. 
Remove-AzVirtualNetworkPeering -Name $PeerPeeringName -VirtualNetworkName $PeerVnetName -ResourceGroupName $PeerRg

# Restablish peering. 
Add-AzVirtualNetworkPeering -Name $PeerPeeringName -VirtualNetwork $PeerVnet -RemoteVirtualNetworkId $Vnet.Id
Add-AzVirtualNetworkPeering -Name $Peer.Name -VirtualNetwork $Vnet -RemoteVirtualNetworkId $PeerVnetId