function Measure-Object {
    <#
    .SYNOPSIS
    Overload of the official cmdlet to provide statistical insights Calculates the numeric properties of objects, and the characters, words, and lines in string objects, such as files of text.
    .NOTES
    Github      : https://github.com/tostka/PowerShell-Statistics
    Tags        : Powershell,Statistics
    REVISIONS
    * 1:59 PM 10/6/2021 added CBH description of breaking behavior of Measure-Object cmdlet, while in use (e.g. you don't want this loaded full time if you use Measure).
    * 4:03 PM 7/20/2021 all mod cmdlets: converted external .md-based docs into CBH (wasn't displaying get-help for cmds when published & installed)
    .DESCRIPTION
    This cmdlet overloads the official implementation and adds several statistical value to the resulting object.
    This includes the median, several percentiles as well as the 95% confidence interval.

    Note:As an overload for the native Measure-Object, with -Property as a *mandated* parameter, this can break other uses of measure-object while loaded (will cause other scripts/functions to prompt: Supply values for the following parameters: Property:). 
    Workaround is to use remove-module -name Statistics, to ensure the native Measure-object is available. 

    The Measure-Object cmdlet calculates the property values of certain types of object.
    Measure-Object performs three types of measurements, depending on the parameters in the command.

    The Measure-Object cmdlet performs calculations on the property values of objects.
    It can count objects and calculate the minimum, maximum, sum, and average of the numeric values.
    For text objects, it can count and calculate the number of lines, words, and characters.
    .PARAMETER  InputObject
    Specifies the objects to be measured.
    Enter a variable that contains the objects, or type a command or expression that gets the objects.

    When you use the InputObject parameter with Measure-Object , instead of piping command results to Measure-Object , the InputObject value-even if the value is a collection that is the result of a command, such as \`-InputObject (Get-Process)\`-is treated as a single object.
    Because InputObject cannot return individual properties from an array or collection of objects, it is recommended that if you use Measure-Object to measure a collection of objects for those objects that have specific values in defined properties, you use Measure-Object in the pipeline, as shown in the examples in this topic.
    .PARAMETER  Property
    Specifies the numeric property to measure

    Specifies one or more numeric properties to measure.
    The default is the Count property of the object.
    .PARAMETER Width
    Length of the bar for the maximum value (width of the graph)INPUTS
    .INPUTS 
    System.Array
    System.Management.Automation.PSObject
    You can pipe objects to Measure-Object.
    System.Management.Automation.PSObject
    You can pipe objects to Measure-Object .
    .OUTPUTS
    System.Object
    .EXAMPLE
    PS> Get-Process | Measure-Object -Property WorkingSet
    Display memory usage of processes
    .EXAMPLE
    PS> Get-ChildItem | Measure-Object
    Count the files and folders in a directory
    .LINK
    https://github.com/tostka/PowerShell-Statistics
    .LINK
    https://en.m.wikipedia.org/wiki/Median
    .LINK
    https://en.m.wikipedia.org/wiki/Variance
    .LINK
    https://en.m.wikipedia.org/wiki/Standard_deviation
    .LINK
    https://en.m.wikipedia.org/wiki/Percentile
    .LINK
    https://en.m.wikipedia.org/wiki/Confidence_interval
    #>
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