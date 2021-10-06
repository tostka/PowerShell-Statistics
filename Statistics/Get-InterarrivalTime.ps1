function Get-InterarrivalTime {
    <#
    .SYNOPSIS
    Calculates time span between each arrival and the next.
    .NOTES
    Github      : https://github.com/tostka/PowerShell-Statistics
    Tags        : Powershell,Statistics
    REVISIONS
    * 4:03 PM 7/20/2021 all mod cmdlets: converted external .md-based docs into CBH (wasn't displaying get-help for cmds when published & installed)
    .DESCRIPTION
    Calculates time span between each arrival and the next.
    .PARAMETER  InputObject
    Input objects containing the relevant data
    .PARAMETER  Property
    Property of the input objects containing the relevant data
    .PARAMETER  Unit
    Unit of measure (Ticks, TotalSecond, Minutes, Hours, Days)
    .INPUTS
    System.Array
    .OUTPUTS
    System.Object
    .EXAMPLE
    PS> 1..10 | ForEach-Object {
        Get-Counter -Counter '\Processor(_Total)\% Processor Time'
        Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5)
    } | ConvertFrom-PerformanceCounter | Get-InterarrivalTime -Property Timestamp
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
        [ValidateSet('Ticks', 'TotalSecond', 'Minutes', 'Hours', 'Days')]
        [string]
        $Unit = 'Ticks'
    )

    Begin {
        Write-Debug ('[{0}] Entering begin block' -f $MyInvocation.MyCommand)
        $PreviousArrival = $null
    }

    Process {
        Write-Debug ('[{0}] Entering process block' -f $MyInvocation.MyCommand)
        $InputObject | ForEach-Object {
            Write-Debug ('[{0}] Processing value' -f $MyInvocation.MyCommand)
            if ($PreviousArrival) {
                Write-Debug ('[{0}] Calculating interarrival time' -f $MyInvocation.MyCommand)
                Add-Member -InputObject $_ -MemberType NoteProperty -Name "Interarrival$Unit" -Value (New-TimeSpan -Start $PreviousArrival.$Property -End $_.$Property | Select-Object -ExpandProperty $Unit) -PassThru
            }
            $PreviousArrival = $_
        }
    }
}

New-Alias -Name giat -Value Get-InterarrivalTime -Force