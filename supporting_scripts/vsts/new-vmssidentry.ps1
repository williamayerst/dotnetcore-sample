$storageAccount = "$env:imageid_storageaccount"
$accesskey = "$env:imageid_storageaccountaccesskey"
 
function InsertReplaceTableEntity($TableName, $PartitionKey, $RowKey, $entity) {
    $version = "2017-04-17"
    $resource = "$tableName(PartitionKey='$PartitionKey',RowKey='$Rowkey')"
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
    $body = $entity | ConvertTo-Json
    $item = Invoke-RestMethod -Method PUT -Uri $table_url -Headers $headers -Body $body -ContentType application/json
}
 
 $body = @{
    RowKey       = "$env:imageid_region"
    PartitionKey = "$env:imageid_version"
    ImageURI      = "$env:imageid_URL"
}

Write-Host "Creating a new table entity" -ForegroundColor yellow
InsertReplaceTableEntity -TableName "images" -RowKey $body.RowKey -PartitionKey $body.PartitionKey -entity $body
