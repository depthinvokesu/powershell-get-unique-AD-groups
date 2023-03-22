$StartTime = $(get-date)

$origin = get-content "groups.txt"
$travelled = New-Object System.Collections.Generic.HashSet[string]
$unique = New-Object System.Collections.Generic.List[string]

Function AreSubgroupsUnique {
    param (
        $grp_lst
    )

    $children = New-Object System.Collections.Generic.HashSet[string]

    foreach ($grp in $grp_lst) {

        if ($grp -in $origin) {
            return $false
        }

        if ($grp -in $travelled) {
            continue
        }
        else {
            $travelled.Add($grp) | Out-Null
        }

        try {
            $sub_lst = (Get-ADGroupMember $grp | where {$_.objectClass -eq "group"}).name
        }
        catch {
            Write-Warning "Unable to find a group ${grp}"
            continue
        }        

        if ($sub_lst.count -ne 0){
            $sub_lst | foreach {$children.Add($_) | Out-Null}
        }
    }

    if ($children.Count -eq 0) {
        return $true
    }

    else {
        return AreSubgroupsUnique -grp_lst $children
    }
}


foreach ($group in $origin) {
    
    $group = $group.Trim()
    write-host $group
    
    if ($grp -in $travelled) {
        Write-Host "group in travelled"
        continue
    }
    else {
        $travelled.Add($grp) | Out-Null
    }

    try {
        $sub_lst = (Get-ADGroupMember $group | where {$_.objectClass -eq "group"}).name
    }
    catch {
        Write-Warning "Unable to find a group ${group}"
        continue
    }

    if ($sub_lst.count -eq 0){
        Write-Host "+ The group has no subgroups, adding to unique list"
        $unique.Add($group) | Out-Null
        continue
    }

    if (AreSubgroupsUnique -grp_lst $sub_lst -eq $true) {
        Write-Host "+ Subgroups of the group aren't in the orig. list, adding to unique list"
        $unique.Add($group) | Out-Null
    }
    else {
        Write-Host "- Some of subgroups is in the original list"
    }
}


Write-Host '---'
Write-Host "Original list of groups:"
$origin

Write-Host "Total amount of groups in original list:", $origin.count

Write-Host '---'
Write-Host "Unique groups:"
$unique

Write-Host "Total amount of unique groups:", $unique.count

Write-Host '---'
$elapsedTime = $(get-date) - $StartTime
$totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
Write-Host $totalTime

pause