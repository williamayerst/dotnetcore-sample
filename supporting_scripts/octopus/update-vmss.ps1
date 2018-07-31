$dynamicimageURL = $OctopusParameters["Octopus.Action[Generate VMSS Image ID URL].Output.imageid.url"]

Write-host "dynamic: >> $dynamicimageURL <<"
write-host "via octopus variables: >> #{imageid.URL} <<"
# get the VMSS model

$vmss = Get-AzureRmVmss -ResourceGroupName #{rgName} -VMScaleSetName #{vmssName}

# set the new version in the model data

$vmss.virtualMachineProfile.storageProfile.osDisk.image.uri=”#{imageid.Url}“

# update the virtual machine scale set model

Update-AzureRmVmss -ResourceGroupName #{rgName} -Name resource_group_name -VirtualMachineScaleSet #{vmssName}
