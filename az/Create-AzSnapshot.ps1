function Create-AzSnapshot {
    <#
        .SYNOPSIS
            Creates snapshots of the disks attached to a virtual machine.

        .DESCRIPTION
            Creates snapshots of the disks attached to a virtual machine.

        .PARAMETER ResourceGroupName
            The name of the resource group containing the virtual machine.

        .PARAMETER VirtualMachineName
            The name of the virtual machine.

        .PARAMETER AllDisks
            If specified, snapshot of all disks will be taken (OS disk and data disks attached).

        .PARAMETER OSDisk
            If specified, snapshot of OS disk will be taken.

        .PARAMETER DataDisks
            If specified, snapshot of data disks will be taken.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory)]
        [string[]]$VirtualMachineName,
        
        [switch]$AllDisks,

        [switch]$OSDisk,

        [switch]$DataDisks
    )
    Write-Verbose "[$((Get-Date).TimeOfDay)] Starting $($MyInvocation.MyCommand)"

    $scriptBlock = {
        param([string]$ResourceGroupName, [string]$VirtualMachineName, [boolean]$AllDisks, [boolean]$OSDisk, [boolean]$DataDisks, [boolean]$Verbose)

        if ($Verbose) {
            $VerbosePreference = 'Continue'
        }

        $vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VirtualMachineName

        try {
            Write-Verbose "[$((Get-Date).TimeOfDay)] Stopping the virtual machine [${VirtualMachineName}]..."
            $null = $vm | Stop-AzVM -ResourceGroupName $ResourceGroupName -Force


            $osd = $vm.StorageProfile.OsDisk.ManagedDisk.Id
            $datad = $vm.StorageProfile.DataDisks.ManagedDisk.Id
            $disks = @(
                if ($AllDisks -or $OSDisk) { $osd }
                if ($AllDisks -or $DataDisks) { $datad }
            )
                
            $snapshotNames = foreach ($disk in $disks) {
                '[{0}] Creating snapshot configuration for disk [{1}] attached to [{2}]...' -f
                @(
                    (Get-Date).TimeOfDay
                    $disk
                    $VirtualMachineName
                ) | Write-Verbose
                $snapshotConfig = New-AzSnapshotConfig -SourceUri $disk -Location $vm.Location -CreateOption Copy
                $diskName = $disk -split '/' | Select-Object -Last 1
                $snapshotName = "${VirtualMachineName}-${diskName}-$(Get-Date -UFormat '%Y%m%d%H%M%S')"
                if ($snapshotName -cmatch 'OsDisk') {
                    $snapshotName = $snapshotName.Substring(0, 80)
                }
                $snapshotName

                '[{0}] Creating the snapshot [{1}]...' -f
                @(
                    (Get-Date).TimeOfDay
                    $snapshotName
                ) | Write-Verbose
                $null = New-AzSnapshot -Snapshot $snapshotConfig -SnapshotName $snapshotName -ResourceGroupName $ResourceGroupName
            }
        }
        catch {
            throw $_.Exception.Message
        }
        finally {
            '[{0}] Starting the virtual machine [{1}]...' -f
            @(
                (Get-Date).TimeOfDay
                $snapshotName
            ) | Write-Verbose
            $null = $vm | Start-AzVM
            [PSCustomObject]@{
                VirtualMachineName = $VirtualMachineName
                SnapshotName       = $snapshotNames
            }
        }
    }
    $jobs = foreach ($Name in $VirtualMachineName) {
        Start-Job -ScriptBlock $scriptBlock -ArgumentList @($ResourceGroupName, $Name, $AllDisks, $OSDisk, $DataDisks, $True)
    }
    $jobs | Receive-Job -Wait -AutoRemoveJob
    Write-Verbose  "[$((Get-Date).TimeOfDay)] Executed all snapshot operations. Waiting on jobs to finish..."
}