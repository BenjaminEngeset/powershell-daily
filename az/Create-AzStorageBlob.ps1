function Create-AzStorageBlob {
    <#
    .SYNOPSIS
        Creates an blob in a container.

    .DESCRIPTION 
        Creates an blob in a container within a storage account.
    
    .PARAMETER StorageAccount
        The name of the storage account where the blob should be created.
    
    .PARAMETER Container
        The name of the container within the storage account where the blob should be created.

    .PARAMETER File
        Specifies a local file path for a file to upload as blob content.

    .PARAMETER Blob
        Specifies the name of the blob to create.

    .PARAMETER BlobType
        Specifies the type for the blob to create. Accepted values are Block, Page, Append.
    
    .PARAMETER Properties
        Specifies properties for the blob to create.
        The supported properties are CacheControl, ContentDisposition, ContentEncoding, ContentLanguage, ContentMD5, ContentType.

    .PARAMETER Metadata
        Specifies metadata for the blob to create.
    
    .PARAMETER Tag
        Tags for the blob to create. In the format @{key0 = value0; key1 = 'value1}.

    .PARAMETER StandardBlobTier
        Block blob tier, accepted values are Hot, Cool, Archive.
    
    .PARAMETER ResourceGroup
        The name of the resource group which contains the storage account.

    .PARAMETER Versioning
        Enables versioning for the blob service of the storage account.
    
    .PARAMETER Force
        Overwrites an existing blob without prompting you for confirmation.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[0-9a-z]{3,24}')]
        [string]$StorageAccount,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateLength(3, 63)]
        [ValidatePattern('^[a-z0-9]+(-[a-z0-9]+)*-?$')]
        [string]$Container,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$File,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateLength(1, 1024)]
        [string]$Blob,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Block', 'Page', 'Append')]
        [string]$BlobType,

        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable]$Properties,

        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable]$Metadata,

        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable]$Tag,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Hot', 'Cool', 'Archive')]
        [string]$StandardBlobTier,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$ResourceGroup,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Versioning,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Force
    )
    
    begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN] Starting $($MyInvocation.MyCommand)"
    }
    
    process {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Creating `"$blob`""
        $context = New-AzStorageContext -StorageAccountName $StorageAccount -UseConnectedAccount
        $PSBoundParameters.Remove('StorageAccount')
        $PSBoundParameters.Remove('Versioning')
        $PSBoundParameters.Remove('ResourceGroup')
        $blobContent = Set-AzStorageBlobContent @PSBoundParameters -Context $context
        if ($Versioning) {
            $usbspSplat = @{
                ResourceGroupName   = $ResourceGroup
                StorageAccountName  = $StorageAccount
                IsVersioningEnabled = $True
            }
            $blobVersioning = Update-AzStorageBlobServiceProperty @usbspSplat
        }
        [PSCustomObject]@{
            PSTypeName          = 'PSStorageBlob'
            LastModified        = $blobContent.LastModified
            Computername        = $env:COMPUTERNAME
            Name                = $blobContent.Name
            Length              = $blobContent.Length
            BlobType            = $blobContent.BlobType
            AccessTier          = $blobContent.AccessTier
            Tags                = $blobContent.Tags
            ContentType         = $blobContent.ContentType
            IsVersioningEnabled = (Get-AzStorageBlobServiceProperty -ResourceGroupName $ResourceGroup -StorageAccountName $StorageAccount).IsVersioningEnabled
            VersionId           = $BlobType.VersionId
            SnapshotTime        = $blobContent.SnapshotTime
            BlobProperties      = $blobContent.BlobProperties    
        }
    }
    
    end {
        Write-Verbose "[$((Get-Date).TimeOfDay) END] Ending $($MyInvocation.MyCommand)"
    }
}
