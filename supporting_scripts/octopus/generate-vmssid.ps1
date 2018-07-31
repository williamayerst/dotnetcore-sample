$storageAccount = "#{imageid.storageaccount}"
$accesskey = "#{imageid.storageaccountaccesskey}"
 
 
function GetTableEntityAll($TableName) {
    $version = "2017-04-17"
    $resource = "$tableName"
    $table_url = "https://$storageAccount.table.core.windows.net/$resource"
    $GMTTime = (Get-Date).ToUniversalTime().toString('R')
    $stringToSign = "$GMTTime`n/$storageAccount/$resource"
    $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
    $hmacsha.key = [Convert]::FromBase64String($accesskey)
    $signature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign))
    $signature = [Convert]::ToBase64String($signature)
    $headers = @{
        'x-ms-date'    = $GMTTime
        Authorization  = "SharedKeyLite " + $storageAccount + ":" + $signature
        "x-ms-version" = $version
        Accept         = "application/json;odata=fullmetadata"
    }
    $item = Invoke-RestMethod -Method GET -Uri $table_url -Headers $headers -ContentType application/json
    return $item.value
}

Write-Host "Getting all table entities"
$tableItems = GetTableEntityAll -TableName images

Write-Host "Filtering all table entities"

$versionItem = $tableItems | `
    Where-Object -Property PartitionKey -eq "#{imageid.version}" | `
    Where-Object -Property Rowkey -eq "#{imageid.region}"

Write-Host "Setting OctopusVariable"

    Set-OctopusVariable -name "imageid.URL" -value $versionItem.imageURL 

# https://wavstscustomeunstornp.blob.core.windows.net/system/Microsoft.Compute/Images/vsts-buildimagetask/20180731.3-osDisk.1f76f07a-4497-40c5-bf8f-31eccb9f4988.vhd