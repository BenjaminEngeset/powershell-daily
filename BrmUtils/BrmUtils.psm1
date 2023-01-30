function Brm-Generate {
    <#
        .SYNOPSIS
            Generates template spec files.

        .DESCRIPTION
            Generates template spec files.

            File Name            | Description
         ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
            metadata.json	     | An JSON file containing template spec metadata. You must edit the file to provide the metadata values.                                                                                                       |
            main.bicep	         | An empty Bicep file that you need to update. This is the main template spec file.                                                                                                                            |
            test/main.test.bicep | A Bicep file to be deployed in the PR merge validation pipeline to test if main.bicep is deployable.You must add at least one test to the file. A module referencing main.bicep is considered a test.        |
            main.json	         | The main ARM template file compiled from main.bicep. This is the artifact that will be published to the Bicep registry. You should not modify the file.                                                      |
            README.md	         | The README file generated based on the contents of metadata.json and main.bicep. You need to update this file to add description and examples.                                                               |
            version.json	     | The template spec version file. It is used together with main.json to calculate the patch version number of the template spec.                                                                               |
                                 | Every time main.json is changed, the patch version number gets bumped.                                                                                                                                       |
                                 | The full version (<TemplateSpecMajorVersion>.<TemplateSpecMinorVersion>.<TemplateSpecPatchVersion>) will then be assigned to the template spec before it gets published to the template spec resource group. |
                                 | The process is handled by the template spec publishing CI automatically. You should not edit this this file.                                                                                                 |
    #>
    [CmdletBinding()]
    param ()
    begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN] Starting $($MyInvocation.MyCommand)"
    }

    process {
        if ((Get-Location).Path -cmatch '\\template-specs\\[a-z0-9]+([._-][a-z0-9]+)*\\[a-z0-9]+([._-][a-z0-9]+)*$') {
            $tsDir = (Get-Location).Path -creplace '(?<![^\\])template-specs(?![^\\])', 'modules'
            $dirToRename = ((Get-Location).Path -split '\\')[0..4] -join '\'
            $newName = $dirToRename -creplace 'template-specs', 'modules'
            Set-Location -Path $env:USERPROFILE
            Rename-Item -Path $dirToRename -NewName $newName
            Set-Location -Path $tsDir
            brm generate
            Set-Location -Path $env:USERPROFILE
            Rename-Item -Path $newName -NewName $dirToRename
            Set-Location -Path ($tsDir -creplace '(?<![^\\])modules(?![^\\])', 'template-specs')
        }
        else {
            throw 'Could not find the directory for the template spec. Navigate to the created folder and invoke the command again from there.'
        }
    }

    end {
        Write-Verbose "[$((Get-Date).TimeOfDay) END] Ending $($MyInvocation.MyCommand)"
    }
}

function Brm-Validate {
    <#
        .SYNOPSIS
            Validates the contents of the template spec files.

        .DESCRIPTION
            Validates the contents of the template spec files.
    #>
    [CmdletBinding()]
    param ()
    begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN] Starting $($MyInvocation.MyCommand)"
    }

    process {
        if ((Get-Location).Path -cmatch '\\template-specs\\[a-z0-9]+([._-][a-z0-9]+)*\\[a-z0-9]+([._-][a-z0-9]+)*$') {
            $tsDir = (Get-Location).Path -creplace '(?<![^\\])template-specs(?![^\\])', 'modules'
            $dirToRename = ((Get-Location).Path -split '\\')[0..4] -join '\'
            $newName = $dirToRename -creplace 'template-specs', 'modules'
            Set-Location -Path $env:USERPROFILE
            Rename-Item -Path $dirToRename -NewName $newName
            Set-Location -Path $tsDir
            brm validate
            Set-Location -Path $env:USERPROFILE
            Rename-Item -Path $newName -NewName $dirToRename
            Set-Location -Path ($tsDir -creplace '(?<![^\\])modules(?![^\\])', 'template-specs')
        }
        else {
            throw 'Could not find the directory for the template spec. Navigate to the template spec folder and invoke the command again from there.'
        }
    }

    end {
        Write-Verbose "[$((Get-Date).TimeOfDay) END] Ending $($MyInvocation.MyCommand)"
    }
}

Export-ModuleMember -Function Brm-Generate, Brm-Validate