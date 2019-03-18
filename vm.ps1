
param(
    $resourceGroupName,
    $location,
    $pipDomainName,
    $nicName,
    $vmName,
    $username,
    $password,
    $vnetName,
    $pipName,
    $networkResourceGroup
)

$securePassword1 = ConvertTo-SecureString -String "Password" -AsPlainText -Force

$cred1 = New-Object System.Management.Automation.PSCredential -ArgumentList xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx, $securePassword1

Login-AzureRmAccount -ServicePrincipal -Tenant xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx -Credential $cred1 

New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

#New-AzureRmStorageAccount -SkuName Standard_LRS -ResourceGroupName vmrg -Name "stforvmmclass" -Location "West Europe" -Kind StorageV2 -AccessTier Hot -Verbose

#$storage = Get-AzureRmStorageAccount -ResourceGroupName vmrg -Name stforvmmclass 

#$subnet = new-AzureRmVirtualNetworkSubnetConfig -Name vmsubnet -AddressPrefix "10.0.1.0/24"

#$vnet = New-AzureRmVirtualNetwork -Name vnet -ResourceGroupName vmrg -Location "West Europe" -AddressPrefix "10.0.0.0/16"  -Force -Verbose

$pip = New-AzureRmPublicIpAddress -Name $pipName -ResourceGroupName $resourceGroupName -Location $location -Sku Basic -AllocationMethod Dynamic `
-DomainNameLabel $pipDomainName -Verbose -Force

#$vnet.Subnets.Add($subnet)

#set-Azurermvirtualnetwork -VirtualNetwork $vnet -Verbose

$vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $networkResourceGroup 

$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $location -SubnetId $vnet.Subnets[0].id `
 -PublicIpAddressId $pip.Id -IpConfigurationName myconfig -Verbose -Force

$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

 $vm = New-AzureRmVMConfig -VMName $vmName -VMSize Standard_A2 `
 | Set-AzureRmVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred `
 | Set-AzureRmVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2016-Datacenter" -Version latest `
 | Add-AzureRmVMNetworkInterface -Id $nic.Id -Primary

 new-Azurermvm -ResourceGroupName $resourceGroupName -Location $location -VM $vm -Verbose 


 
$app = New-AzureRmADApplication -DisplayName vmscriptdemo -IdentifierUris "http://vmscriptdemo" -HomePage "http://vmscriptdemo" `
-Password (ConvertTo-SecureString -String Password -AsPlainText -Force)


New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId.Guid -DisplayName vmscriptdemo `
-Password (ConvertTo-SecureString -String Password -AsPlainText -Force) -Role Owner -Verbose








