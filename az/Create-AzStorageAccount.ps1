function Create-AzStorageAccount {
    <#
        .SYNOPSIS
            Creates an storage account.

        .DESCRIPTION
            Creates an storage account with essential configuration.

        .PARAMETER ResourceGroupName
            The resource group name where the storage account should be deployed.
        
        .PARAMETER Name
            The name of the storage account to create, must follow the pattern '^[0-9a-z]{3,24}'.
        
        .PARAMETER Location 
            The location for the storage account, such as 'westeurope'.
        
        .PARAMETER SkuName
            The SKU for the storage account, such as 'Standard_LRS'.
        
        .PARAMETER Kind
            The kind for the storage account, such as 'StorageV2'.
        
        .PARAMETER AccessTier
            The access tier for the storage account, such as 'Cool'.
    
        .PARAMETER Tag
            The tags that can be applied to the storage account, in format @{key0 = 'value0'; key1 = 'value1'}.
        
        .PARAMETER EnableHttpsTrafficOnly
            Allow only HTTPS traffic to the storage account. Anything else will be dropped.
        
        .PARAMETER MinimumTlsVersion
            The minimum TLS version to be permitted on requests to storage.

        .PARAMETER AllowBlobPublicAccess
            Allow public access to all blobs or containers in the storage account.
        
        .PARAMETER PublicNetworkAccess
            Allow or disallow public network access to the storage account.
        
        .PARAMETER SecurityBaseline
            Switch parameter for enabling security enhancements that are not default. HTTPS traffic only, minimum TLS version 1.2 and blob allow blob public access to false.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('rg')]
        [string]$ResourceGroupName,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('n')]
        [ValidatePattern('^[0-9a-z]{3,24}')]
        [string]$Name,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('l')]
        [string]$Location,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('sku')]
        [ValidateSet('Standard_LRS', 'Standard_ZRS', 'Standard_GRS', 'Standard_RAGRS', 'Premium_LRS', 'Premium_ZRS', 'Standard_GZRS', 'Standard_RAGZRS')]
        [string]$SkuName,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('k')]
        [ValidateSet('Storage', 'StorageV2', 'BlobStorage', 'BlockBlobStorage', 'FileStorage')]
        [string]$Kind,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('tier')]
        [ValidateSet('Hot', 'Cool')]
        [string]$AccessTier,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('t')]
        [hashtable]$Tag,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('httpsonly')]
        [boolean]$EnableHttpsTrafficOnly,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('mintls')]
        [ValidateSet('TLS1_0', 'TLS1_1', 'TLS1_2')]
        [string]$MinimumTlsVersion,
        [Parameter(ValueFromPipelineByPropertyName)]
        [boolean]$AllowBlobPublicAccess,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$PublicNetworkAccess,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$SecurityBaseline
    )
    
    begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN] Starting $($MyInvocation.MyCommand)"
    }
    
    process {
        if ($PSBoundParameters.ContainsKey('SecurityBaseline')) {
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Security baseline was specified, setting the baseline."
            $PSBoundParameters.Remove('SecurityBaseline')
            $PSBoundParameters['EnableHttpsTrafficOnly'] = $True
            $PSBoundParameters['MinimumTlsVersion'] = 'TLS1_2'
            $PSBoundParameters['AllowBlobPublicAccess'] = $False
        }

        $storage = New-AzStorageAccount @PSBoundParameters
        if ($storage.ProvisioningState -eq 'Succeeded') {
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Storage account `"$($storage.StorageAccountName)`" was created."
        }
        else {
            Write-Warning "[$((Get-Date).TimeOfDay) PROCESS] Storage account `"$($storage.StorageAccountName)`" did not provision successfully."
        }
        if ($storage) {
            [PSCustomObject]@{
                PSTypeName         = 'PSStorageAccount'
                CreationTime       = $storage.CreationTime
                ProvisioningState  = $storage.ProvisioningState
                Computername       = $env:COMPUTERNAME
                StorageAccountName = $storage.StorageAccountName
                ResourceGroupName  = $storage.ResourceGroupName
                Location           = $storage.PrimaryLocation
                Sku                = ($storage.Sku.Name)
                Kind               = $storage.Kind
                AccessTier         = $storage.AccessTier
                HttpsTrafficOnly   = $storage.EnableHttpsTrafficOnly
                MinimumTLSVersion  = $storage.MinimumTlsVersion
            }
        }
    }

    end {
        Write-Verbose "[$((Get-Date).TimeOfDay) END] Ending $($MyInvocation.MyCommand)"
    }
}