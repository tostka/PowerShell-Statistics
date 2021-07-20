function Expand-DateTime {
    <#
    .SYNOPSIS
    convert timestamps for legibility
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
    .EXAMPLE
    PS> 1..10 | ForEach-Object {
    Get-Counter -Counter '\Processor(_Total)\% Processor Time'
        } | ConvertFrom-PerformanceCounter | ForEach-Object {
            [pscustomobject]@{
                Timestamp = $_.Timestamp.DateTime
                Value     = $_.Value
            }
        } | Expand-DateTime -Property Timestamp
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
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Property = 'Timestamp'
    )

    Process {
        Write-Debug ('[{0}] Entering process block' -f $MyInvocation.MyCommand)
        $InputObject | ForEach-Object {
            Write-Debug 'inside foreach'
            if (-Not (Get-Member -InputObject $_ -MemberType Properties -Name $Property)) {
                throw ('[{0}] Unable to find property <{1}> in input object' -f $MyInvocation.MyCommand, $Property)
            }

            $DateTimeExpanded = $_.$Property
            if ($DateTimeExpanded -isnot [System.DateTime]) {
                Write-Debug 'inside if'
                $DateTimeExpanded = Get-Date -Date $_.$Property
                $_.$Property = $DateTimeExpanded
            }

            foreach ($DateTimeProperty in @('DayOfWeek')) {
                Add-Member -InputObject $_ -MemberType NoteProperty -Name $DateTimeProperty -Value $DateTimeExpanded.$DateTimeProperty
            }
            foreach ($DateTimeProperty in @('Year', 'Month', 'Hour')) {
                Add-Member -InputObject $_ -MemberType NoteProperty -Name $DateTimeProperty -Value ([int]($DateTimeExpanded.$DateTimeProperty))
            }
            Add-Member -InputObject $_ -MemberType NoteProperty -Name WeekOfYear -Value ([int](Get-Date -Date $_.$Property -UFormat '%V'))

            $_
        }
    }
}

New-Alias -Name edt -Value Expand-DateTime -Force