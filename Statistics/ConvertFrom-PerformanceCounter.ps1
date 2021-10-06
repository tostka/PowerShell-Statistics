function ConvertFrom-PerformanceCounter {
    <#
    .SYNOPSIS
    Add-Bar.ps1 - Restructure get-counter data to make it easier to process
    .NOTES
    Github      : https://github.com/tostka/PowerShell-Statistics
    Tags        : Powershell,Statistics
    REVISIONS
    * 4:03 PM 7/20/2021 all mod cmdlets: converted external .md-based docs into CBH (wasn't displaying get-help for cmds when published & installed)
    .DESCRIPTION
    Restructure get-counter data to make it easier to process
    .PARAMETER  InputObject
    Input objects containing the relevant data
    .PARAMETER  Instance
    Property of the input objects containing the relevant data
    .INPUTS
    System.Array
    .OUTPUTS
    System.Object
    .EXAMPLE
    PS> Get-counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 2 -MaxSamples 100 | ConvertFrom-PerformanceCounter
    .LINK
    https://github.com/tostka/PowerShell-Statistics
    #>
    <#
    .SYNOPSIS
    Add-Bar.ps1 - Visualizes values using bars
    .NOTES
    Github      : https://github.com/tostka/PowerShell-Statistics
    Tags        : Powershell,Statistics
    REVISIONS
    .DESCRIPTION
    A graphical representation help understanding data.
    Add-Bar adds a new member to the input objects which contain bars to visualize the size of the value relative to the maximum value

    .PARAMETER  InputObject
    Input objects containing the relevant data
    .PARAMETER  Property
    Property of the input objects containing the relevant data
    .PARAMETER Width
    Length of the bar for the maximum value (width of the graph)
    .EXAMPLE
    PS> Add-Bar -InputObject $Files -Property Length
    .EXAMPLE
    PS> $Files | Add-Bar -Property Length
    .LINK
    https://github.com/tostka/PowerShell-Statistics
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [array]
        $InputObject
        ,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Instance
    )

    Process {
        $InputObject | ForEach-Object {
            [pscustomobject]@{
                Timestamp = $_.Timestamp
                Value     = $_.CounterSamples | Where-Object { $_.InstanceName -ieq $Instance } | Select-Object -ExpandProperty CookedValue
            }
        }
    }
}

New-Alias -Name cfpc -Value ConvertFrom-PerformanceCounter -Force