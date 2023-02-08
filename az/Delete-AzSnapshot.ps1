function Delete-AzSnapshot {
    <#
    .SYNOPSIS
        Deletes snapshot.

    .DESCRIPTION
        Deletes snapshot in a resource group.
    
    .PARAMETER ResourceGroupName
        The name of the resource group containing the snapshot.
    
    .PARAMETER Name
        The name of the snapshot.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$Name
    )

    begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN] Starting $($MyInvocation.MyCommand)"
    }
    process {
        foreach ($n in $Name) {
            '[{0} PROCESS] Removing snapshot [{1}] from the resource group [{2}]' -f
            @(
                (Get-Date).TimeOfDay
                $n
                $ResourceGroupName
            ) | Write-Verbose
        }
    }
    end {
        Write-Verbose "[$((Get-Date).TimeOfDay) END] Ending $($MyInvocation.MyCommand)"
    }
}