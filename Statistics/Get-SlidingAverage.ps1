function Get-SlidingAverage {
    <#
    .SYNOPSIS
    Calculates a sliding average over a window of the specified size
    .NOTES
    Github      : https://github.com/tostka/PowerShell-Statistics
    Tags        : Powershell,Statistics
    REVISIONS
    * 4:03 PM 7/20/2021 all mod cmdlets: converted external .md-based docs into CBH (wasn't displaying get-help for cmds when published & installed)
    .DESCRIPTION
    Calculates a sliding average over a window of the specified size:
    .PARAMETER  InputObject
    Input objects containing the relevant data
    .PARAMETER  Property
    Property of the input objects containing the relevant data
    .PARAMETER Size
    The sample window over which to calculate the average
    .EXAMPLE
    PS> Get-Counter -Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 10 |
     ConvertFrom-PerformanceCounter -Instance _total | 
     Get-SlidingAverage -Property Value -Size 5 ; 
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
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]
        $Size = 5
    )

    Begin {
        Write-Debug ('[{0}] Size of queue is <{1}>' -f $MyInvocation.MyCommand, $q.Count)
        $q = New-Object -TypeName System.Collections.Queue -ArgumentList $Size
    }

    Process {
        $InputObject | ForEach-Object {
            if (-Not (Get-Member -InputObject $_ -MemberType Properties -Name $Property)) {
                throw ('[{0}] Unable to find property <{1}> in input object' -f $MyInvocation.MyCommand, $Property)
            }

            #region Enqueue new item and trim to specified size
            $q.Enqueue($_)
            Write-Debug ('[{0}] Size of queue is <{1}>' -f $MyInvocation.MyCommand, $q.Count)
            if ($q.Count -gt $Size) {
                $q.Dequeue() | Out-Null
            }
            #endregion

            #region Calculate average if the specified number of items is present
            if ($q.Count -eq $Size) {
                $q | Microsoft.PowerShell.Utility\Measure-Object -Property $Property -Average | Select-Object -ExpandProperty Average
            }
            #endregion
        }
    }
}

New-Alias -Name gsa -Value Get-SlidingAverage -Force
