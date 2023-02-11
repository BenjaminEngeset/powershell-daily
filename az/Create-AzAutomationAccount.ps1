function Create-AzAutomationAccount {
    <#
        .SYNOPSIS
            Creates an automation account.
        
        .DESCRIPTION
            Creates an automation account.

        .PARAMETER ResourceGroupName
            The name of the resource group where the automation account should be deployed.
        
        .PARAMETER Name
            The name of the automation account to to create.
        
        .PARAMETER Location
            The location for the automation account, defaults to the same as the resource group location.
        
        .PARAMETER Plan
            The plan for the automation account, allowed values are Free, Basic.
        
        .PARAMETER AssignSystemManagedIdentity
            If specified, system-managed identity will be enabled for the automation account (useful for child resources later on).
        
        .PARAMETER Tags
            The tags for the automation account, must be in the format @{key0 = 'value0'; key1 = 'value1'}.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[-\w\._\(\)]*[-\w_\(\)]$')]
        [ValidateLength(1, 90)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[a-z-A-Z][0-9a-z-A-Z]{4,48}[0-9]$')]
        [ValidateLength(6, 50)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Location = (Get-AzResourceGroup -Name $ResourceGroupName).Location,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Free', 'Basic')]
        [string]$Plan = 'Free',
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$AssignSystemManagedIdentity,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.IDictionary]$Tags
    )
    begin {
        '[{0} BEGIN] Starting [{1}]' -f @(
            (Get-Date).TimeOfDay
            $MyInvocation.MyCommand
        ) | Write-Verbose
    }
    
    process {
        '[{0} PROCESS] Creating the automation account [{1}]' -f @(
            (Get-Date).TimeOfDay
            $Name
        ) | Write-Verbose
        $PSBoundParameters['Location'] = $Location
        $PSBoundParameters['Plan'] = $Plan
        if ($AssignSystemManagedIdentity) {
            $null = $PSBoundParameters.Remove('AssignSystemManagedIdentity')
        }
        $account = New-AzAutomationAccount @PSBoundParameters
        if ($AssignSystemManagedIdentity) {
            $null = Set-AzAutomationAccount -ResourceGroupName $account.ResourceGroupName -Name $account.AutomationAccountName -AssignSystemIdentity
        }
        Get-AzAutomationAccount -ResourceGroupName $account.ResourceGroupName -Name $account.AutomationAccountName
    }

    end {
        '[{0} END] Ending {1}' -f @(
            (Get-Date).TimeOfDay
            $MyInvocation.MyCommand
        ) | Write-Verbose
    }
}