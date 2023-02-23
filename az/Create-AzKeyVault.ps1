function Create-AzKeyVault {
    <#
        .SYNOPSIS
            Creates an key vault.
        
        .DESCRIPTION
            Creates an key vault.
        
        .PARAMETER Name
            The name of the key vault to create.
        
        .PARAMETER ResourceGroupName
            The resource group where the key vault should be deployed.

        .PARAMETER Location
            The location for the key vault.
            Defaults to the same location as the resource group.
        
        .PARAMETER SoftDeleteRetentionInDays
            Soft-delete retention for the key vault. Allowed values are between 0-90.
            If 0 is applied, it will be treated as non soft-delete applied.

        .PARAMETER EnablePurgeProtection
            Enable purge protection for the key vault.

        .PARAMETER EnableRbacAuthorization
            Enable RBAC authorization access model.

        .PARAMETER PublicNetworkAccess
            Enable public network access for the key vault.
            Allowed values are either Enabled or Disabled.
            Defaults to Enabled.

        .PARAMETER Sku
            The SKU for the key vault.
            Allowed values are either Standard or Premium.
            Defaults to Standard.
        
        .PARAMETER subscriptionId
            The ID of the subscription. By default, cmdlets are executed in the subscription that is set in the current context. 
            If the user specifies another subscription, the current cmdlet is executed in the subscription specified by the user.
            Overriding subscriptions only take effect during the lifecycle of the current cmdlet. 
            It does not change the subscription in the context, and does not affect subsequent cmdlets.
        
        .PARAMETER Tag
            The tags to be applied to the key vault. In the format @{key0 = 'value0'; key1 = 'key1'}.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidatePattern('[A-Z-a-z](-|[A-Za-z0-9])*[A-Za-z0-9]$')]
        [ValidateLength(3, 24)]
        [string[]]$Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateLength(1, 90)]
        [string]$ResourceGroupName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Location = (Get-AzResourceGroup -Name $ResourceGroupName).Location,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(0, 90)]
        [int]$SoftDeleteRetentionInDays,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$EnablePurgeProtection,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$EnableRbacAuthorization,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Enabled', 'Disabled')]
        [string]$PublicNetworkAccess = 'Enabled',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Standard', 'Premium')]
        [string]$Sku = 'Standard',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ $_ -as [guid] })]
        [string]$subscriptionId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable]$Tag
    )
    
    begin {
        '[{0} BEGIN] Starting {1}' -f @(
            (Get-Date).TimeOfDay
            $MyInvocation.MyCommand
        ) | Write-Verbose
    }
    
    process {
        foreach ($kv in $Name) {
            '[{0} PROCESS] Processing {1}' -f @(
                (Get-Date).TimeOfDay
                $kv
            ) | Write-Verbose

            $kvSplat = @{
                Name                = $kv
                ResourceGroupName   = $ResourceGroupName
                Location            = $Location
                PublicNetworkAccess = $PublicNetworkAccess
                Sku                 = $Sku
            }
            foreach ($prop in 'SoftDeleteRetentionInDays', 'EnablePurgeProtection', 'EnableRbacAuthorization', 'SubscriptionId', 'Tag') {
                if ($PSBoundParameters.ContainsKey($prop)) {
                    $kvSplat[$prop] = $PSBoundParameters[$prop]
                }
            }
            New-AzKeyVault @kvSplat
        }
    }
    
    end {
        '[{0} END] Ending {1}' -f @(
            (Get-Date).TimeOfDay
            $MyInvocation.MyCommand
        ) | Write-Verbose
    }
}