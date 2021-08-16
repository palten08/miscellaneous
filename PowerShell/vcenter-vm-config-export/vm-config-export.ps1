Param(
    [Parameter(Mandatory=$true)][string] $vCenterURL,
    [Parameter(Mandatory=$true)][string] $SessionID,
    [Parameter(Mandatory=$true)][string[]] $FolderNames,
    [Parameter()][string] $ExportFileName = "C:\Temp\VMInventory.csv"
)

$AuthenticationHeader = @{ "vmware-api-session-id" = $SessionID }

$APIBase = "$vCenterURL/rest/vcenter"

class CsvRow {
    [string]${Server Name}
    [int]${vCPU}
    [int]${Memory}
    [int]${Storage}
}

$OutputArray = @()

Write-Host -ForegroundColor Cyan "Gathering VM info"

ForEach ($Folder in $FolderNames) {
    $FolderRequestURI = "$($APIBase)/folder?filter.names=$Folder"
    $FolderRequest = Invoke-RestMethod -Uri $FolderRequestURI -Method Get -Headers $AuthenticationHeader
    $FolderID = $FolderRequest.value.folder
    
    $VMListRequestURI = "$($APIBase)/vm?filter.folders=$($FolderID)"
    $VMListRequest = Invoke-RestMethod -Uri $VMListRequestURI -Method Get -Headers $AuthenticationHeader

    ForEach ($ListItem in $VMListRequest.value) {
        $VMID = $ListItem.vm
        $VMRequestURI = "$($APIBase)/vm/$($VMID)"
        $VMRequest = Invoke-RestMethod -Uri $VMRequestURI -Method Get -Headers $AuthenticationHeader

        $VMName = $VMRequest.value.name
        $VMMemory = [math]::Round($VMRequest.value.memory.size_MiB / 954)
        $VMCPU = $VMRequest.value.cpu.count

        $VMStorageTotal = 0

        ForEach ($Disk in $VMRequest.value.disks) {
            $VMStorageTotal += $($Disk.value.capacity / 1GB)
        }

        $RowObject = [CsvRow]::new()

        $RowObject.'Server Name' = $VMName
        $RowObject.'vCPU' = $VMCPU
        $RowObject.'Memory' = $VMMemory
        $RowObject.'Storage' = $VMStorageTotal

        $OutputArray += $RowObject
    }
}

$OutputArray | Export-Csv $ExportFileName

Write-Host -ForegroundColor Magenta "CSV Exported to $($ExportFileName)"