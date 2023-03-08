function Create-AzUserAssignedIdentity {
    <#
        .SYNOPSIS
            Creates an user-assigned identity.

        .DESCRIPTION
            Creates an user-assigned identity.

        .PARAMETER Name
            The name for the user-assigned identity to be created.

        .PARAMETER ResourceGroupName
            The resource group where the user-assigned identity should be deployed.

        .PARAMETER Location
            The location for the user-assigned identity.
            Defaults to the same location as the resource group.

        .PARAMETER SubscriptionId
            The subscription id where the user-assigned identity should be deployed.
            Defaults to to the same id as the context.

        .PARAMETER Tag
            The tags to be applied to the  user-assigned identity.
            In the format: @{key0 = 'value0'; key1 = 'value1'}
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[A-Za-z0-9][\w]{2,127}$')]
        [ValidateLength(3, 128)]
        [string]$Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$ResourceGroupName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Location = ($ResourceGroupName | Get-AzResourceGroup).Location,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SubscriptionId = (Get-AzContext).Subscription.Id,

        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable]$Tag
    )
    
    process {
        $PSBoundParameters['Location'] = $Location
        $PSBoundParameters['SubscriptionId'] = $SubscriptionId
        New-AzUserAssignedIdentity @PSBoundParameters
    }
}