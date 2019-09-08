function Measure-Object {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [array]
        $Data
        ,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Property
    )

    End {
        #region Percentiles require sorted data
        # If the argument for the Data parameter was not provided via pipeline set the input to the provided argument
        # otherwise use the automatic Input variable
        if (!$PSCmdlet.MyInvocation.ExpectingInput) {
            $Input = $Data
        }
        $Input = $Input | Sort-Object -Property $Property
        #endregion

        #region Grab basic measurements from upstream Measure-Object
        $Stats = $Input | Microsoft.PowerShell.Utility\Measure-Object -Property $Property -Minimum -Maximum -Sum -Average
        #endregion
        
        #region Calculate median
        Write-Debug ('[{0}] Number of data items is <{1}>' -f $MyInvocation.MyCommand.Name, $Input.Count)
        if ($Input.Count % 2 -eq 0) {
            Write-Debug ('[{0}] Even number of data items' -f $MyInvocation.MyCommand.Name)

            $MedianIndex = ($Input.Count / 2) - 1
            Write-Debug ('[{0}] Index of Median is <{1}>' -f $MyInvocation.MyCommand.Name, $MedianIndex)
            
            $LowerMedian = $Input[$MedianIndex] | Select-Object -ExpandProperty $Property
            $UpperMedian = $Input[$MedianIndex + 1] | Select-Object -ExpandProperty $Property
            Write-Debug ('[{0}] Lower Median is <{1}> and upper Median is <{2}>' -f $MyInvocation.MyCommand.Name, $LowerMedian, $UpperMedian)
            
            $Median = ([double]$LowerMedian + [double]$UpperMedian) / 2
            Write-Debug ('[{0}] Average of lower and upper Median is <{1}>' -f $MyInvocation.MyCommand.Name, $Median)

        }
        else {
            Write-Debug ('[{0}] Odd number of data items' -f $MyInvocation.MyCommand.Name)

            $MedianIndex = [math]::Ceiling(($Input.Count - 1) / 2)
            Write-Debug ('[{0}] Index of Median is <{1}>' -f $MyInvocation.MyCommand.Name, $MedianIndex)

            $Median = $Input[$MedianIndex] | Select-Object -ExpandProperty $Property
            Write-Debug ('[{0}] Median is <{1}>' -f $MyInvocation.MyCommand.Name, $Median)
        }
        Add-Member -InputObject $Stats -MemberType NoteProperty -Name 'Median' -Value $Median
        #endregion

        #region Calculate variance
        $Variance = 0
        foreach ($_ in $Input) {
            $Variance += [math]::Pow($_.$Property - $Stats.Average, 2) / $Stats.Count
        }
        $Variance /= $Stats.Count
        Add-Member -InputObject $Stats -MemberType NoteProperty -Name 'Variance' -Value $Variance
        #endregion

        #region Calculate standard deviation
        $StandardDeviation = [math]::Sqrt($Stats.Variance)
        Add-Member -InputObject $Stats -MemberType NoteProperty -Name 'StandardDeviation' -Value $StandardDeviation
        #endregion

        #region Calculate percentiles
        $Percentile10Index = [math]::Ceiling(10 / 100 * $Input.Count)
        $Percentile25Index = [math]::Ceiling(25 / 100 * $Input.Count)
        $Percentile75Index = [math]::Ceiling(75 / 100 * $Input.Count)
        $Percentile90Index = [math]::Ceiling(90 / 100 * $Input.Count)
        Add-Member -InputObject $Stats -MemberType NoteProperty -Name 'Percentile10' -Value $Input[$Percentile10Index].$Property
        Add-Member -InputObject $Stats -MemberType NoteProperty -Name 'Percentile25' -Value $Input[$Percentile25Index].$Property
        Add-Member -InputObject $Stats -MemberType NoteProperty -Name 'Percentile75' -Value $Input[$Percentile75Index].$Property
        Add-Member -InputObject $Stats -MemberType NoteProperty -Name 'Percentile90' -Value $Input[$Percentile90Index].$Property
        #endregion

        #region Calculate Tukey's range for outliers
        $TukeysOutlier = 1.5
        $TukeysRange = $TukeysOutlier * ($Stats.Percentile75 - $Stats.Percentile25)
        Add-Member -InputObject $Stats -MemberType NoteProperty -Name TukeysRange -Value $TukeysRange
        #endregion

        #region Calculate confidence intervals
        $z = @{
            '90' = 1.645
            '95' = 1.96
            '98' = 2.326
            '99' = 2.576
        }
        $Confidence95 = $z.95 * $Stats.StandardDeviation / [math]::Sqrt($Stats.Count)
        Add-Member -InputObject $Stats -MemberType NoteProperty -Name 'Confidence95' -Value $Confidence95
        #endregion

        #region Return measurements
        $Stats
        #endregion
    }
}

New-Alias -Name mo -Value Measure-Object -Force