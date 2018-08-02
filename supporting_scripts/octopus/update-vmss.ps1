$dynamicimageURL = $OctopusParameters["Octopus.Action[Generate VMSS Image ID URL].Output.outputimageidurl"]

Write-host "via output variable: >> $dynamicimageURL <<"
# get the VMSS model

$vmss = Get-AzureRmVmss -ResourceGroupName $rgName -VMScaleSetName $vmssName

# set the new version in the model data

$vmss.virtualMachineProfile.storageProfile.osDisk.image.uri=$dynamicimageURL

# update the virtual machine scale set model

Update-AzureRmVmss -ResourceGroupName $rgName -Name $vmssName -VirtualMachineScaleSet $vmss
