$storageAccount = '#{imageid.storageaccount}'
$accesskey = '#{imageid.storageaccountaccesskey}'
$imageregion = '#{imageid.region}'
$imageversion = '#{imageid.version}'

write-host "Connecting to $storageaccount"
write-host "Getting imageID for region: $imageregion and version: $imageversion"
 
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

$tableItems | ft rowkey,partitionkey,imageURI 

Write-Host "Filtering all table entities"

$versionItem = $tableItems | Where {$_.PartitionKey -eq $imageversion -and $_.RowKey -eq $imageregion}

Write-Host "Setting OctopusVariable to $($versionItem.imageURI)"

Set-OctopusVariable -name "outputimageidurl" -value $($versionItem.imageURI)
