function Create-AzStorageContainer {
    <#
        .SYNOPSIS
            Creates an container in a storage account.

        .DESCRIPTION
            Creates an private (non-public) container in a storage account specified.
        ´
        .PARAMETER StorageAccountName
            The name of the (existing) storage account where the container should be created.

        .PARAMETER Name
            The name of the container to create.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[0-9a-z]{3,24}')]
        [string]$StorageAccountName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateLength(3, 63)]
        [ValidatePattern('^[a-z0-9]+(-[a-z0-9]+)*-?$')]
        [string]$Name
    )
    
    begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN] Starting $($MyInvocation.MyCommand)"
    }
    
    process {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Processing.. Creating a storage context for `"$StorageAccountName`""
        $context = New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Processing.. Creating a container `"$Name`" in the storage account `"$StorageAccountName`""
        $container = New-AzStorageContainer -Name $Name -Permission Off -Context $context
        [PSCustomObject]@{
            PSTypeName          = 'PSStorageAccountContainer'
            LastModified        = $container.LastModified
            Computername        = $env:COMPUTERNAME
            Name                = $container.Name
            ContainerProperties = $container.BlobContainerProperties
            PublicAccess        = $container.PublicAccess
            Permission          = $container.Permission
        }
    }

    end {
        Write-Verbose "[$((Get-Date).TimeOfDay) END] Ending $($MyInvocation.MyCommand)"
    }
}
