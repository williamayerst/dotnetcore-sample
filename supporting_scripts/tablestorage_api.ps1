$storageAccount = "CHANGEME"
$accesskey = "CHANGEME"
 
 
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
 
function MergeTableEntity($TableName, $PartitionKey, $RowKey, $entity) {
    $version = "2017-04-17"
    $resource = "$tableName(PartitionKey='$PartitionKey',RowKey='$Rowkey')"
    $table_url = "https://$storageAccount.table.core.windows.net/$resource"
    $GMTTime = (Get-Date).ToUniversalTime().toString('R')
    $stringToSign = "$GMTTime`n/$storageAccount/$resource"
    $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
    $hmacsha.key = [Convert]::FromBase64String($accesskey)
    $signature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign))
    $signature = [Convert]::ToBase64String($signature)
    $body = $entity | ConvertTo-Json
    $headers = @{
        'x-ms-date'      = $GMTTime
        Authorization    = "SharedKeyLite " + $storageAccount + ":" + $signature
        "x-ms-version"   = $version
        Accept           = "application/json;odata=minimalmetadata"
        'If-Match'       = "*"
        'Content-Length' = $body.length
    }
    $item = Invoke-RestMethod -Method MERGE -Uri $table_url -Headers $headers -ContentType application/json -Body $body
 
}
 
function DeleteTableEntity($TableName, $PartitionKey, $RowKey) {
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
        Accept         = "application/json;odata=minimalmetadata"
        'If-Match'     = "*"
    }
    $item = Invoke-RestMethod -Method DELETE -Uri $table_url -Headers $headers -ContentType application/http
 
}
 
 
$body = @{
    RowKey       = "RegionA"
    PartitionKey = "Version1"
    ImageURI      = "https://EXAMPLEURL"
}



Write-Host "Creating a new table entity" -ForegroundColor yellow
InsertReplaceTableEntity -TableName "images" -RowKey $body.RowKey -PartitionKey $body.PartitionKey -entity $body

Write-Host "Getting all table entities"  -ForegroundColor yellow
$tableItems = GetTableEntityAll -TableName "images"
  

#InsertReplaceTableEntity -TableName "Testing" -RowKey $body.RowKey -PartitionKey $body.PartitionKey -entity $body
 
#Write-Host "Merging with an existing table entity"
#MergeTableEntity -TableName "Testing" -RowKey $body.RowKey -PartitionKey $body.PartitionKey -entity $body
 
#Write-Host "Deleting an existing table entity"
#DeleteTableEntity -TableName "Testing" -RowKey $body.RowKey -PartitionKey $body.PartitionKey