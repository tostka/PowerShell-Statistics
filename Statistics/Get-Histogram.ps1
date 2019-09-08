function Get-Histogram {
    [CmdletBinding(DefaultParameterSetName = 'BucketCount')]
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
        ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [float]
        $Minimum
        ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [float]
        $Maximum
        ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('Width')]
        [float]
        $BucketWidth = 1
        ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('Count')]
        [float]
        $BucketCount
    )
    Begin {
        # Define default display properties
        $ddps = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]('Index', 'Count', 'lowerBound', 'upperBound'))
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]$ddps
    }
    End {
        Write-Verbose ('[{0}] Building histogram' -f $MyInvocation.MyCommand)
        # If the argument for the Data parameter was not provided via pipeline set the input to the provided argument
        # otherwise use the automatic Input variable
        if (!$PSCmdlet.MyInvocation.ExpectingInput) {
            $Input = $Data
        }
        Write-Debug ('[{0}] Retrieving measurements from upstream cmdlet for {1} values' -f $MyInvocation.MyCommand, $Input.Count)
        Write-Progress -Activity 'Measuring data'

        $Stats = $Input | Microsoft.PowerShell.Utility\Measure-Object -Minimum -Maximum -Property $Property

        if (-Not $PSBoundParameters.ContainsKey('Minimum')) {
            $Minimum = $Stats.Minimum
            Write-Debug ('[{0}] Minimum value not specified. Using smallest value ({1}) from input data.' -f $MyInvocation.MyCommand, $Minimum)
        }
        if (-Not $PSBoundParameters.ContainsKey('Maximum')) {
            $Maximum = $Stats.Maximum
            Write-Debug ('[{0}] Maximum value not specified. Using largest value ({1}) from input data.' -f $MyInvocation.MyCommand, $Maximum)
        }
        if (-Not $PSBoundParameters.ContainsKey('BucketCount')) {
            $BucketCount = [math]::Ceiling(($Maximum - $Minimum) / $BucketWidth)
            Write-Debug ('[{0}] Bucket count not specified. Calculated {1} buckets from width of {2}.' -f $MyInvocation.MyCommand, $BucketCount, $BucketWidth)
        }
        if ($BucketCount -gt 100) {
            Write-Warning ('[{0}] Generating {1} buckets' -f $MyInvocation.MyCommand, $BucketCount)
        }

        Write-Debug ('[{0}] Building buckets using: Minimum=<{1}> Maximum=<{2}> BucketWidth=<{3}> BucketCount=<{4}>' -f $MyInvocation.MyCommand, $Minimum, $Maximum, $BucketWidth, $BucketCount)
        Write-Progress -Activity 'Creating buckets'
        $OverallCount = 0
        $Buckets = 1..$BucketCount | ForEach-Object {
            [pscustomobject]@{
                Index         = $_
                lowerBound    = $Minimum + ($_ - 1) * $BucketWidth
                upperBound    = $Minimum + $_ * $BucketWidth
                Count         = 0
                RelativeCount = 0
                Group         = New-Object -TypeName System.Collections.ArrayList
                PSTypeName    = 'HistogramBucket'
            }
        }

        Write-Debug ('[{0}] Building histogram' -f $MyInvocation.MyCommand)
        $DataIndex = 1
        foreach ($_ in $Input) {
            $Value = $_.$Property

            Write-Progress -Activity 'Filling buckets' -PercentComplete ($DataIndex / $Input.Count * 100)
            
            if ($Value -ge $Minimum -and $Value -le $Maximum) {
                $BucketIndex = [math]::Floor(($Value - $Minimum) / $BucketWidth)
                if ($BucketIndex -lt $Buckets.Length) {
                    $Buckets[$BucketIndex].Count += 1
                    [void]$Buckets[$BucketIndex].Group.Add($_)
                    $OverallCount += 1
                }
            }

            ++$DataIndex
        }

        Write-Debug ('[{0}] Adding relative count and default properties' -f $MyInvocation.MyCommand)
        foreach ($_ in $Buckets) {
            # Add an type name to make the default properties work
            [void]$_.PSObject.TypeNames.Insert(0, 'Statistics.Buckets')
            # Attach default display property set
            Add-Member -InputObject $_ -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers
            $_.RelativeCount = if ($OverallCount -gt 0) { $_.Count / $OverallCount } else { 0 }
        }

        Write-Debug ('[{0}] Returning histogram' -f $MyInvocation.MyCommand)
        $Buckets

    }
}

New-Alias -Name ghist -Value Get-Histogram -Force