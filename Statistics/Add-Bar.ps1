function Add-Bar {
    <#
    .SYNOPSIS
    Add-Bar.ps1 - Visualizes values using bars
    .NOTES
    Github      : https://github.com/tostka/PowerShell-Statistics
    Tags        : Powershell,Statistics
    REVISIONS
    * 4:03 PM 7/20/2021 all mod cmdlets: converted external .md-based docs into CBH (wasn't displaying get-help for cmds when published & installed)
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
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [array]
        $Data
        ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Property = 'Count'
        ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]
        $Width = $( if ($Host.UI.RawUI.MaxWindowSize.Width) { $Host.UI.RawUI.MaxWindowSize.Width - 30 } else { 50 } )
    )

    End {
        # If the argument for the Data parameter was not provided via pipeline set the input to the provided argument
        # otherwise use the automatic Input variable
        if (!$PSCmdlet.MyInvocation.ExpectingInput) {
            $Input = $Data
        }
        foreach ($_ in $Input) {
            if (-Not (Get-Member -InputObject $_ -MemberType Properties -Name $Property)) {
                throw ('Input object does not contain a property called <{0}>.' -f $Property)
            }
        }
        
        Write-Verbose ('[{0}] Adding bars for width {1}' -f $MyInvocation.MyCommand, $Width)

        $Count = $Input| Microsoft.PowerShell.Utility\Measure-Object -Maximum -Property $Property | Select-Object -ExpandProperty Maximum
        Write-Debug ('[{0}] Maximum value is {1}. This value will be {2} characters long.' -f $MyInvocation.MyCommand, $Count, $Width)

        $Bars = foreach ($_ in $Input) {
            $RelativeCount = [math]::Round($_.$Property / $Count * $Width, 0)
            Write-Debug ('[{0}] Value of {1} will be displayed using {2} characters.' -f $MyInvocation.MyCommand, $_.Property, $RelativeCount)

            Write-Debug ('[{0}] Adding member to input object.' -f $MyInvocation.MyCommand)
            $Item = $_ | Select-Object -Property Index, $Property | Add-Member -MemberType NoteProperty -Name Bar -Value ('#' * $RelativeCount) -PassThru

            Write-Debug ('[{0}] Adding type name to output object.' -f $MyInvocation.MyCommand)
            $Item.PSTypeNames.Insert(0, 'HistogramBar')

            Write-Debug ('[{0}] Returning output object.' -f $MyInvocation.MyCommand)
            $Item
        }

        Write-Debug ('[{0}] Returning input objects with bars.' -f $MyInvocation.MyCommand)
        $Bars
    }
}

New-Alias -Name ab -Value Add-Bar -Force