try {
    $searchOU = $ADgroupsSearchOU
    Write-Information "SearchBase: $searchOU"
    $ous = $searchOU | ConvertFrom-Json
         
    $groups = foreach($item in $ous) {
        Get-ADGroup -Filter {Name -like '*'} -SearchBase $item.ou | Select-Object name
    }
     
    $groups = $groups | Sort-Object -Property name
    $resultCount = @($groups).Count
     
    Write-Information "Result count: $resultCount"

    if($resultCount -gt 0){
        foreach($adGroup in $groups){
            $returnObject = @{name="$($adGroup.name)";}
            Write-Output $returnObject
        }
    }
} catch {
    Write-Error "Error searching for AD groups. Error: $($_.Exception.Message)"
}
