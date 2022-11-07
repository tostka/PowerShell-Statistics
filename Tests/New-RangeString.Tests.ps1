﻿#Get-ChildItem -Path "$env:BHModulePath" -Filter '*.ps1' -File | ForEach-Object {
#    . "$($_.FullName)"
#}

if ($env:PSModulePath -notlike '*Statistics*') {
    $env:PSModulePath = "$((Get-Item -Path "$PSScriptRoot\..").FullName);$env:PSModulePath"
}

Import-Module -Name Statistics -Force -ErrorAction 'Stop'

Describe 'New-RangeString' {
    It 'Works with both indexes in bounds' {
        New-RangeString -Width 10 -LeftIndex  2 -RightIndex  8 | Should Be ' |-----|'
    }
    It 'Works with left index out of bounds' {
        New-RangeString -Width 10 -LeftIndex -2 -RightIndex  8 | Should Be '<------|'
    }
    It 'Works with both right index out of bounds' {
        New-RangeString -Width 10 -LeftIndex  2 -RightIndex 12 | Should Be ' |------->'
    }
    It 'Works with both indexes out of bounds' {
        New-RangeString -Width 10 -LeftIndex -2 -RightIndex 12 | Should Be '<-------->'
    }
    It 'Works with identical indexes' {
        New-RangeString -Width 10 -LeftIndex  2 -RightIndex  2 | Should Be ' ||'
    }
    It 'Works with zero indexes' {
        New-RangeString -Width 10 -LeftIndex  0 -RightIndex  0 | Should Be '||'
    }
}
