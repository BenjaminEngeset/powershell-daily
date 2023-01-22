function Create-AzResourceGroup {
    <#
        .SYNOPSIS
            Creates an resource group.
        
        .DESCRIPTION
            Creates an resource group within a subscription context.
        
        .PARAMETER Name
            The name of the resource group to create.
        
        .PARAMETER Location
            The location where the resource group should be deployed.

        .PARAMETER Tag
            The tags that can be applied to the resource group, in format @{key0 = 'value0'; key1 = 'value1'}.

        .PARAMETER ResourceGroupLock
            The resource group lock that can be applied, valid values are 'CanNotDelete', 'ReadOnly' and 'None'.
            The value 'None' is the same as not declaring the parameter.
        
        .PARAMETER Force
            Switch parameter to force the command to run without asking for user confirmation.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('n')]
        [ValidatePattern('^[-\w\._\(\)]*[-\w_\(\)]$')]
        [string]$Name,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('l')]
        [string]$Location,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('t')]
        [hashtable]$Tag,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('lock')]
        [ValidateSet('CanNotDelete', 'ReadOnly', 'None')]
        [string]$ResourceGroupLock,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Force
    )
    
    begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN] Starting $($MyInvocation.MyCommand)"  
    }
    
    process {
        if ($PSBoundParameters.ContainsKey('ResourceGroupLock')) { $PSBoundParameters.Remove('ResourceGroupLock') }
        $resourceGroup = New-AzResourceGroup @PSBoundParameters
        if ($resourceGroup.ProvisioningState -eq 'Succeeded') {
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Resource group `"$($resourceGroup.ResourceGroupName)`" was created."
        }
        else {
            Write-Warning "[$((Get-Date).TimeOfDay) PROCESS] Resource group `"$($resourceGroup.ResourceGroupName)`" did not provision successfully."
        }
        if ($ResourceGroupLock -in 'CanNotDelete', 'ReadOnly') {
            $lockNotes = @('Cannot delete resource or child resources.', 'Cannot modify the resource or child resources.')
            $rlsplat = @{  
                LockName          = "${Name}-${ResourceGroupLock}-lock"
                LockLevel         = $ResourceGroupLock
                LockNotes         = if ($ResourceGroupLock -eq 'CanNotDelete') { $lockNotes[0] } else { $lockNotes[1] }
                ResourceGroupName = $resourceGroup.ResourceGroupName
            }
            if ($PSBoundParameters.ContainsKey('Force')) {
                $rlsplat.Add('Force', $True)
            }
            $lock = New-AzResourceLock @rlsplat
            if ($lock) {
                Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Resource group lock `"$($lock.Name)`" was created."
            }
        }
        if ($resourceGroup) {
            $output = [PSCustomObject]@{
                PSTypeName        = 'PSResourceGroup'
                ProvisioningState = $resourceGroup.ProvisioningState
                Computername      = $env:COMPUTERNAME
                CreationTime      = ((Get-Date).AddSeconds(-5)) # Not accurate, object returned does not include creation time.
                Name              = $resourceGroup.ResourceGroupName
                Location          = $resourceGroup.Location
                ResourceId        = $resourceGroup.ResourceId
            }
            if ($PSBoundParameters.ContainsKey('Tag')) {
                $output = $output | Select-Object -Property *, @{ n = 'Tags'; e = { ($resourceGroup.Tags) } }
            }
            if ($ResourceGroupLock) {
                $output = $output | Select-Object -Property *, @{ n = 'ResourceGroupLockLevel'; e = { $ResourceGroupLock } }
            }
            $output
        }
    }
    
    end {
        Write-Verbose "[$((Get-Date).TimeOfDay) END] Ending $($MyInvocation.MyCommand)"
    }
}