function Show-Measurement {
    <#
    .SYNOPSIS
    Visualizes statistical data about input values
    .NOTES
    Github      : https://github.com/tostka/PowerShell-Statistics
    Tags        : Powershell,Statistics
    REVISIONS
    .DESCRIPTION
    Show-Measurement relies on the overload of Measure-Object provided by this module.
    It visualizes the data calculated by Measure-Object on the console.
    .PARAMETER  InputObject
    Input objects containing the relevant data
    .PARAMETER  Property
    Property of the input objects containing the relevant data
    .PARAMETER Width
    Maximum number of characters to display per line
    .PARAMETER PassThru
    {{Fill PassThru Description}}
    .INPUTS
    System.Object
    .OUTPUTS
    System.Object
    .EXAMPLE
    PS> Get-Process | Measure-Object -Property WorkingSet | Show-Measurement
---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
P10
 P25
         A
      c-----C
   M
            P75
                        P90
---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
    .LINK
    https://github.com/tostka/PowerShell-Statistics
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [object]
        $Data
        ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]
        $Width = $( if ($Host.UI.RawUI.MaxWindowSize.Width) { $Host.UI.RawUI.MaxWindowSize.Width - 25 } else { 90 } )
        ,
        [switch]
        $PassThru
    )

    End {
        #region Generate visualization of measurements
        $AvgSubDevIndex = [math]::Round(($Data.Average - $Data.StandardDeviation) / $Data.Maximum * $Width, 0)
        $AvgIndex = [math]::Round( $Data.Average / $Data.Maximum * $Width, 0)
        $AvgAddDevIndex = [math]::Round(($Data.Average + $Data.StandardDeviation) / $Data.Maximum * $Width, 0)
        $AvgSubConfIndex = [math]::Round(($Data.Average - $Data.Confidence95) / $Data.Maximum * $Width, 0)
        $AvgAddConfIndex = [math]::Round(($Data.Average + $Data.Confidence95) / $Data.Maximum * $Width, 0)
        $MedIndex = [math]::Round( $Data.Median / $Data.Maximum * $Width, 0)
        $P10Index = [math]::Round( $Data.Percentile10 / $Data.Maximum * $Width, 0)
        $P25Index = [math]::Round( $Data.Percentile25 / $Data.Maximum * $Width, 0)
        $P75Index = [math]::Round( $Data.Percentile75 / $Data.Maximum * $Width, 0)
        $P90Index = [math]::Round( $Data.Percentile90 / $Data.Maximum * $Width, 0)
        $P25SubTukIndex = [math]::Round(($Data.Percentile25 - $Data.TukeysRange) / $Data.Maximum * $Width, 0)
        $P75AddTukIndex = [math]::Round(($Data.Percentile75 + $Data.TukeysRange) / $Data.Maximum * $Width, 0)

        Write-Debug "P10=$P10Index P25=$P25Index A=$AvgIndex M=$MedIndex sA=$AvgSubDevIndex As=$AvgAddDevIndex cA=$AvgSubConfIndex aC=$AvgAddConfIndex o=$P25SubTukIndex O=$P75AddTukIndex P75=$P75Index P90=$P90Index"

        $graph = @()
        $graph += 'Range             : ' + '---------|' * ($Width / 10)
        $graph += '10% Percentile    : ' + ' ' * $P10Index + 'P10'
        $graph += '25% Percentile    : ' + ' ' * $P25Index + 'P25'
        $graph += 'Average           : ' + ' ' * $AvgIndex + 'A'
        $graph += 'Standard Deviation: ' + (New-RangeString -Width $Width -LeftIndex $AvgSubDevIndex  -RightIndex $AvgAddDevIndex  -LeftIndicator 's' -RightIndicator 'S')
        $graph += '95% Confidence    : ' + (New-RangeString -Width $Width -LeftIndex $AvgSubConfIndex -RightIndex $AvgAddConfIndex -LeftIndicator 'c' -RightIndicator 'C')
        $graph += 'Tukeys Range      : ' + (New-RangeString -Width $Width -LeftIndex $P25SubTukIndex  -RightIndex $P75AddTukIndex  -LeftIndicator 'o' -RightIndicator 'O')
        $graph += 'Median            : ' + ' ' * $MedIndex + 'M'
        $graph += '75% Percentile    : ' + ' ' * $P75Index + 'P75'
        $graph += '90% Percentile    : ' + ' ' * $P90Index + 'P90'
        $graph += 'Range             : ' + '---------|' * ($Width / 10)
        #endregion

        #region Return graph
        if ($PassThru) {
            $Data
        }
        Write-Host ($graph -join "`n")
        #endregion
    }
}

New-Alias -Name sm -Value Show-Measurement -Force