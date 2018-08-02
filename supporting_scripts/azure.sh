# Request auto-upgrade prieview
az feature register --name AutoOSUpgradePreview --namespace Microsoft.Compute

# register provider with AutoOSUpgradePreview
az provider register -n Microsoft.Compute

# set vmss to automaticOSupgrade (only on base images, it seems??)
az vmss update --name $vmssname --resource-group $rgname --set upgradePolicy.AutomaticOSUpgrade=true

# set VMSS to update model automatically
az vmss update --name $vmssname --resource-group $rgname --set upgradePolicy.mode=automatic # or rolling, if health probe