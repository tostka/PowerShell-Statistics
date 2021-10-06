function Get-WeightedValue {
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
    .PARAMETER WeightProperty
    Weight given to a data point to assign it a lighter, or heavier, importance in a group
    .EXAMPLE
    PS> {{ Add example code here }}
    .LINK
    https://github.com/tostka/PowerShell-Statistics
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [array]
        $InputObject
        ,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Property
        ,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $WeightProperty
    )

    Process {
        $InputObject | ForEach-Object {
            if (-Not (Get-Member -InputObject $_ -MemberType Properties -Name $Property)) {
                throw ('[{0}] Unable to find property <{1}> in input object' -f $MyInvocation.MyCommand, $Property)
            }
            if (-Not (Get-Member -InputObject $_ -MemberType Properties -Name $WeightProperty)) {
                throw ('[{0}] Unable to find weight property <{1}> in input object' -f $MyInvocation.MyCommand, $WeightProperty)
            }

            [pscustomobject]@{
                Value = $_.$WeightProperty * $_.$Property
            }
        }
    }
}

New-Alias -Name gwv -Value Get-WeightedValue -Force