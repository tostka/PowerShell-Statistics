function Measure-Group {
    <#
    .SYNOPSIS
    {{Fill in the Synopsis}}
    .NOTES
    Github      : https://github.com/tostka/PowerShell-Statistics
    Tags        : Powershell,Statistics
    REVISIONS
    * 4:03 PM 7/20/2021 all mod cmdlets: converted external .md-based docs into CBH (wasn't displaying get-help for cmds when published & installed)
    .DESCRIPTION
    {{Fill in the Description}}
    .PARAMETER  InputObject
    Input objects containing the relevant data
    .PARAMETER  Property
    Property of the input objects containing the relevant data
    .PARAMETER Width
    Length of the bar for the maximum value (width of the graph)
    .INPUTS
    Microsoft.PowerShell.Commands.GroupInfo[]
    .OUTPUTS
    System.Object
    .EXAMPLE
    PS> {{ Add example code here }}
    .LINK
    https://github.com/tostka/PowerShell-Statistics
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.PowerShell.Commands.GroupInfo[]]
        $InputObject
        ,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Property
    )

    Process {
        $InputObject | ForEach-Object {
            $Measurement = Measure-Object -Data $_.Group -Property $Property

            Add-Member -InputObject $Measurement -MemberType NoteProperty -Name Name -Value $_.Name -PassThru
        }
    }
}

New-Alias -Name mg -Value Measure-Group -Force
