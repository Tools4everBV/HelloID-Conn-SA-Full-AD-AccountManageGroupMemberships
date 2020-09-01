
try {
    Hid-Write-Status -Message "SearchBase: $searchOU" -Event Information
    $ous = $searchOU | ConvertFrom-Json
         
    $groups = foreach($item in $ous) {
        Get-ADGroup -Filter {Name -like '*'} -SearchBase $item.ou | Select-Object name
    }
     
    $groups = $groups | Sort-Object -Property name
    $resultCount = @($groups).Count
     
    Hid-Write-Status -Message "Result count: $resultCount" -Event Information
    HID-Write-Summary -Message "Result count: $resultCount" -Event Information
     
    if($resultCount -gt 0){
        foreach($adGroup in $groups){
            $returnObject = @{name="$($adGroup.name)";}
            Hid-Add-TaskResult -ResultValue $returnObject
        }
    } else {
        Hid-Add-TaskResult -ResultValue []
    }
} catch {
    HID-Write-Status -Message "Error searching for AD groups. Error: $($_.Exception.Message)" -Event Error
    HID-Write-Summary -Message "Error searching for AD groups" -Event Failed
     
    Hid-Add-TaskResult -ResultValue []
}