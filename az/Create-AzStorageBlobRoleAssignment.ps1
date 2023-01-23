function Create-AzStorageBlobRoleAssignment {
    <#
        .SYNOPSIS
            Creates an blob role assignment on a storage account, or on a child resource within a storage account.

        .DESCRIPTION
            Creates an blob role assignment on a storage account, or on a child resource within a storage account.
        
        .PARAMETER ObjectId
            The Azure AD object id of the user, group or service principal.

        .PARAMETER RoleDefinitionName
            The name of the role to apply, currently a limited set of roles are available aimed at blob permissions.
        
        .PARAMETER ResourceGroupName
            The name of the resource group where the storage account and the child resources are to be found.
        
        .PARAMETER ResourceName
            The resource name where the role assignment should be applied.

        .PARAMETER ResourceType
            The resource type for the resource where the role assignment should be applied.
        
        .PARAMETER ParentResource
            The parent resource. Only to be used if the role assignment should be applied to a child resource. Used to construct an URI.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ObjectId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('role')]
        [ValidateSet('Storage Account Contributor', 'Storage Blob Data Contributor', 'Storage Blob Data Owner', 'Storage Blob Data Reader')]
        [string]$RoleDefinitionName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('rg')]
        [string]$ResourceGroupName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('r')]
        [string]$ResourceName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$ResourceType,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ParentResource
    )
    
    begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN] Starting $($MyInvocation.MyCommand)"
    }
    
    process {
        New-AzRoleAssignment @PSBoundParameters
    }
    
    end {
        Write-Verbose "[$((Get-Date).TimeOfDay) END] Ending $($MyInvocation.MyCommand)"
    }
}