$list = New-Object System.Collections.Generic.List[System.Object]
$subscriptions = Get-AzSubscription

Foreach ($sub in $subscriptions) {
    Write-Host "Searching $($sub.name)" -ForegroundColor Green
    Select-AzSubscription -Subscription $sub.Name | Out-Null
    $resources = Get-AzResource
    foreach ($res in $Resources) {
    
        $resId = $res.ResourceId
        $diagnosticSetting = Get-AzDiagnosticSetting -ResourceId $resId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
            
        If ($diagnosticSetting.WorkspaceId -ne $null) {
            Write-Host "diagnostic settings found for $($res.name)"
            $resourceDiagnostic = [PSCustomObject]@{ 
                "workspaceId"      = $diagnosticSetting.WorkspaceId
                "workspaceName"    = ($diagnosticSetting.WorkspaceId).Split("/")[8]
                "diagnosticName"   = $diagnosticSetting.Name
                "resourceName"     = $res.Name
                "resourceType"     = $res.ResourceType
                "resourceId"       = $res.ResourceId
                "subscriptionName" = $sub.Name
            }
                
            $list.Add($resourceDiagnostic)
        }
    }
}

$filter | Group-Object -p subscriptionName | 
foreach { 
    Select-AzSubscription $_.Name ; ForEach-Object { $azDiagNosticSetting = ($_.group) ; $azDiagNosticSetting | 
        foreach { Remove-AzDiagnosticSetting -ResourceId $_.resourceId -Name $_.diagnosticName ; 
            write-host "Removing diagnostic settings for $($_.resourceName) in $($_.subscriptionName), old workspace: $($_.workspaceName)" -f green } } }