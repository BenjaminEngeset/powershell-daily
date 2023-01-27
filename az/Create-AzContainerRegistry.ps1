function Create-AzContainerRegistry {
    <#
        .SYNOPSIS
            Creates an container registry.
        
        .DESCRIPTION 
            Creates an container registry.

        .PARAMETER ResourceGroupName
            The name of the resource group where the container registry should be deployed.
        
        .PARAMETER Name
            The name of the container registry to create.
        
        .PARAMETER Location
            The location for the container registry, if not specified, defaults to the location of the resource group.

        .PARAMETER Sku
            The container registry SKU. Allowed values are Basic, Standard, Premium.

        .PARAMETER EnableAdminUser
            Enable admin user for the container registry.
        
        .PARAMETER SoftDeleteRetention
            Enable soft delete with an retention period for the container registry. It's possible to set the retention period
            value between one to 90 days.
        
        .PARAMETER Tag
            The tags for the container registry. Must be in the format @{key0 = 'value0'; key1 = 'value1'}
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateLength(1, 90)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidatePattern('[\p{L}\p{Nd}]')]
        [ValidateLength(5, 50)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Location,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('Basic', 'Standard', 'Premium')]
        [string]$Sku,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$EnableAdminUser,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(1, 90)]
        [int]$SoftDeleteRetention,

        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable]$Tag
    )
    begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN] Starting $($MyInvocation.MyCommand)"
    }
    
    process {
        '[{0} PROCESS] Creating the container registry "{1}"' -f @(
                (Get-Date).TimeOfDay
            $Name
        ) | Write-Verbose
        if ($SoftDeleteRetention) {
            $PSBoundParameters.Remove('SoftDeleteRetention')
            $registry = New-AzContainerRegistry @PSBoundParameters
            $subscriptionId = $registry.Id -split '/' | Where-Object { $_ -as [guid] }
            $Uri = @(
                "https://management.azure.com/subscriptions/${SubscriptionId}"
                "/resourceGroups/${ResourceGroupName}/providers/Microsoft.ContainerRegistry/registries/${Name}?api-version=2022-02-01-preview"
            ) -join ''
            $payload = [ordered]@{
                Properties = @{ policies = @{ softDeletePolicy = @{ retentionDays = $SoftDeleteRetention; status = 'enabled' } } }
            } | ConvertTo-Json -Depth 99
            $patchParams = @{
                Uri     = $Uri
                Method  = 'PATCH'
                payload = $payload
            }
            $enableSoftDelete = Invoke-AzRestMethod @patchParams
        }
        else {
            $registry = New-AzContainerRegistry @PSBoundParameters
        }
        $getParams = @{
            ResourceGroupName    = $registry.ResourceGroupName
            ResourceProviderName = ($registry.type -split '/' | Select-Object -First 1)
            ResourceType         = ($registry.type -split '/' | Select-Object -Last 1)
            Name                 = $registry.Name
            ApiVersion           = '2022-02-01-preview'
            Method               = 'GET'
        }
        $status = Invoke-AzRestMethod @getParams
        $softDeletePolicy = ($status.Content | ConvertFrom-Json).properties.policies.softDeletePolicy | Select-Object -Property status, retentionDays
        $output = [PSCustomObject]@{
            PSTypeName        = 'PSContainerRegistry'
            CreationDate      = $registry.CreationDate
            ProvisioningState = $registry.ProvisioningState
            RegistryName      = $registry.Name
            ResourceGroupName = $registry.ResourceGroupName
            Id                = $registry.Id
            ResourceType      = $registry.Type
            Location          = $registry.Location
            LoginServer       = $registry.LoginServer
            AdminUserEnabled  = $registry.AdminUserEnabled
            SoftDeleteEnabled = $softDeletePolicy
            SkuName           = $registry.SkuName
            NetworkRuleSet    = $registry.NetworkRuleSet
        }
        $output
    }
    
    end {
        Write-Verbose "[$((Get-Date).TimeOfDay) END] Ending $($MyInvocation.MyCommand)"
    }
}