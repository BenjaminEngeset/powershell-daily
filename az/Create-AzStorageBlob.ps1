function Create-AzStorageBlob {
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

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Force
    )
    
    begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN] Starting $($MyInvocation.MyCommand)"
    }
    
    process {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Creating blob content.."
        $context = New-AzStorageContext -StorageAccountName $StorageAccount -UseConnectedAccount
        $PSBoundParameters.Remove('StorageAccount')
        $blobContent = Set-AzStorageBlobContent @PSBoundParameters -Context $context
        [PSCustomObject]@{
            PSTypeName     = 'PSStorageBlob'
            LastModified   = $blobContent.LastModified
            Computername   = $env:COMPUTERNAME
            Name           = $blobContent.Name
            Length         = $blobContent.Length
            BlobType       = $blobContent.BlobType
            AccessTier     = $blobContent.AccessTier
            Tags           = $blobContent.Tags
            ContentType    = $blobContent.ContentType
            VersionId      = $BlobType.VersionId
            SnapshotTime   = $blobContent.SnapshotTime
            BlobProperties = $blobContent.BlobProperties
            
        }
    }
    
    end {
        Write-Verbose "[$((Get-Date).TimeOfDay) END] Ending $($MyInvocation.MyCommand)"
    }
}
