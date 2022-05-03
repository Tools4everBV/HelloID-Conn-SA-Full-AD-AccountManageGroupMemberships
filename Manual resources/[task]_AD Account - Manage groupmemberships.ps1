$VerbosePreference = "SilentlyContinue"
$InformationPreference = "Continue"
$WarningPreference = "Continue"

# variables configured in form
$groupsToAdd = $form.memberships.leftToRight
$groupsToRemove = $form.memberships.RightToLeft
$userPrincipalName = $form.gridUsers.UserPrincipalName

Write-Verbose "Groups to add: $groupsToAdd"
Write-Verbose "Groups to remove: $groupsToRemove"

try {
    $adUser = Get-ADuser -Filter { UserPrincipalName -eq $userPrincipalName }
    Write-Information "Found AD user [$userPrincipalName]"
} catch {
    Write-Error "Could not find AD user [$userPrincipalName]. Error: $($_.Exception.Message)"
}

foreach($group in $groupsToAdd){
    try{
        $addGroupMember = Add-ADGroupMember -Identity $group.name -Members $adUser
        Write-Information "Successfully added AD user [$userPrincipalName] to AD group $($group)"
    
        $userDisplayName = $adUser.DisplayName
        $userId = $([string]$adUser.SID)
        $Log = @{
            Action            = "GrantMembership" # optional. ENUM (undefined = default) 
            System            = "ActiveDirectory" # optional (free format text) 
            Message           = "Successfully added AD user $userDisplayName to group $($group)" # required (free format text) 
            IsError           = $false # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
            TargetDisplayName = $userDisplayName # optional (free format text) 
            TargetIdentifier  = $userId # optional (free format text) 
        }
        #send result back  
        Write-Information -Tags "Audit" -MessageData $log
    } catch {
        Write-Error "Could not add AD user [$userPrincipalName] to AD group $group. Error: $($_.Exception.Message)"

        $userDisplayName = $adUser.DisplayName
        $userId = $([string]$adUser.SID) 
        $Log = @{
            Action            = "GrantMembership" # optional. ENUM (undefined = default) 
            System            = "ActiveDirectory" # optional (free format text) 
            Message           = "Failed to add AD user $userDisplayName to group $($group). Error: $($_.Exception.Message)" # required (free format text) 
            IsError           = $true # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
            TargetDisplayName = $userDisplayName # optional (free format text) 
            TargetIdentifier  = $userId # optional (free format text) 
        }
        #send result back  
        Write-Information -Tags "Audit" -MessageData $log
    }
}


foreach($group in $groupsToRemove){
    try{
        $removeGroupMember = Remove-ADGroupMember -Identity $group.name -Members $adUser
        Write-Information "Successfully removed AD user [$userPrincipalName] from AD group $($group)"
    
        $userDisplayName = $adUser.DisplayName
        $userId = $([string]$adUser.SID)
        $Log = @{
            Action            = "RevokeMembership" # optional. ENUM (undefined = default) 
            System            = "ActiveDirectory" # optional (free format text) 
            Message           = "Successfully removed AD user $userDisplayName from group $($group)" # required (free format text) 
            IsError           = $false # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
            TargetDisplayName = $userDisplayName # optional (free format text) 
            TargetIdentifier  = $userId # optional (free format text) 
        }
        #send result back  
        Write-Information -Tags "Audit" -MessageData $log
    } catch {
        Write-Error "Could not remove AD user [$userPrincipalName] from AD group $group. Error: $($_.Exception.Message)"

        $userDisplayName = $adUser.DisplayName
        $userId = $([string]$adUser.SID) 
        $Log = @{
            Action            = "GrantMembership" # optional. ENUM (undefined = default) 
            System            = "ActiveDirectory" # optional (free format text) 
            Message           = "Failed to remove AD user $userDisplayName from group $($group). Error: $($_.Exception.Message)" # required (free format text) 
            IsError           = $true # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
            TargetDisplayName = $userDisplayName # optional (free format text) 
            TargetIdentifier  = $userId # optional (free format text) 
        }
        #send result back  
        Write-Information -Tags "Audit" -MessageData $log
    }
}
