function Migrate-AzContainerRegistryImage {
    <#
        .SYNOPSIS
            Migrates an image from a container registry to a container registry.
        
        .DESCRIPTION
            Migrates an image in a repository from a source container registry to a target container registry.
        
        .PARAMETER SourceRegistryName
            The name of the source container registry containing the images.
        
        .PARAMETER SourceResourceGroupName
            The name of the resource group where the source container registry is at.
        
        .PARAMETER TargetRegistryName
            The name of the target container registry that is recieving images.
        
        .PARAMETER TargetResourceGroupName
            The name of the resource group where the target container registry is at.
        
        .PARAMETER ExcludedRepository
            The name of the repositories (therefore the underlaying images) that should be exluded from the migration.

        .PARAMETER Mode
            When Force, any existing target tags will be overwritten. When NoForce, any existing target tags will fail the operation before any copying begins.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidatePattern('[\p{L}\p{Nd}]')]
        [ValidateLength(5, 50)]
        [string]$SourceRegistryName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateLength(1, 90)]
        [string]$SourceResourceGroupName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidatePattern('[\p{L}\p{Nd}]')]
        [ValidateLength(5, 50)]
        [string]$TargetRegistryName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateLength(1, 90)]
        [string]$TargetResourceGroupName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$ExcludedRepository,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Force', 'NoForce')]
        [string]$Mode = 'NoForce'
    )
    
    begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN] Starting $($MyInvocation.MyCommand)"
    }
    
    process {
        $repositories = @(Get-AzContainerRegistryRepository -RegistryName $SourceRegistryName)
        if ($ExcludedRepository) { $repositories = $repositories | Where-Object { $_ -notin $ExcludedRepository } }
        '[{0} PROCESS] Found {1} repositor{2}' -f
        @(
            (Get-Date).TimeOfDay
            $repositories.Count
            $repositories.Count -ne 1 ? 'ies' : 'y'
        ) | Write-Verbose
    
        $tags = foreach ($repository in $repositories) {
            $tagsRepository = Get-AzContainerRegistryTag -RegistryName $SourceRegistryName -RepositoryName $repository
            '[{0} PROCESS] Found {1} tag{2} in the repository "{3}"' -f
            @(
                (Get-Date).TimeOfDay
                $tagsRepository.Tags.Name.Count
                $tagsRepository.Tags.Name.Count -ne 1 ? 's' : ''
                $repository
            ) | Write-Verbose
            $tagsRepository.Tags.Name | ForEach-Object { $repository, $_ -join ':' }
        }
        '[{0} PROCESS] Found {1} tag{2} in total in the container registry "{3}"' -f
        @(
            (Get-Date).TimeOfDay
            $tags.Count
            $tags.Count -ne 1 ? 's' : ''
            $SourceRegistryName
        ) | Write-Verbose

        $sourceRegistryResourceId = (Get-AzContainerRegistry -Name $SourceRegistryName -ResourceGroupName $SourceResourceGroupName).Id
        foreach ($tag in $tags) {
            '[{0} PROCESS] Importing the tag "{1}" from the source container registry "{2}" to the target container registry "{3}"' -f
            @(
                (Get-Date).TimeOfDay
                $tag
                $SourceRegistryName
                $TargetRegistryName
            ) | Write-Verbose
            $import = Import-AzContainerRegistryImage -RegistryName $TargetRegistryName -ResourceGroupName $TargetResourceGroupName -SourceRegistryResourceId $sourceRegistryResourceId -SourceImage $tag -Mode $Mode
            [PSCustomObject]@{
                PSTypeName         = 'PSContainerRegistryImport'
                Computername       = $env:Computername
                SourceRegistryName = $SourceRegistryName
                TargetRegistryName = $TargetRegistryName
                Tag                = $tag
                SuccessfulImport   = $import
            }
        }
    }
    
    end {
        "[$((Get-Date).TimeOfDay) END] Ending $($MyInvocation.MyCommand)"
    }
}