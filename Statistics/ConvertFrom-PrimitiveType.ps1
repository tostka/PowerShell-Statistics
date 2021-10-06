function ConvertFrom-PrimitiveType {
    <#
    .SYNOPSIS
    Wraps values in objects
    .NOTES
    Github      : https://github.com/tostka/PowerShell-Statistics
    Tags        : Powershell,Statistics
    REVISIONS
    * 4:03 PM 7/20/2021 all mod cmdlets: converted external .md-based docs into CBH (wasn't displaying get-help for cmds when published & installed)
    .DESCRIPTION
    The cmdlet accepts values in primitive types and wraps them in a new object
    .PARAMETER  InputObject
    Input objects containing the relevant data
    .EXAMPLE
    PS> 1..10 | ConvertFrom-PrimitiveType

    Value
    -----
        1
        2
        3
        4
        5
        6
        7
        8
        9
       10
    .LINK
    https://github.com/tostka/PowerShell-Statistics
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $InputObject
    )

    Process {
        Write-Debug ('[{0}] Entered process block' -f $MyInvocation.MyCommand)

        $InputObject | ForEach-Object {
            if (-Not $_.GetType().IsPrimitive) {
                throw ('[{0}] Value is not a primitive type' -f $MyInvocation.MyCommand)
            }

            [pscustomobject]@{
                Value = $_
            }
        }
    }
}

New-Alias -Name cfpt -Value ConvertFrom-PrimitiveType -Force