#Get-ChildItem -Path "$env:BHModulePath" -Filter '*.ps1' -File | ForEach-Object {
#    . "$($_.FullName)"
#}

if ($env:PSModulePath -notlike '*Statistics*') {
    $env:PSModulePath = "$((Get-Item -Path "$PSScriptRoot\..").FullName);$env:PSModulePath"
}

Import-Module -Name Statistics -Force -ErrorAction 'Stop'

Describe 'Show-Measurement' {
    $data = 0..10 | ConvertFrom-PrimitiveType
    $stats = Measure-Object -Data $data -Property Value
    # Could not get the mock working
    It 'Produces output' {
        Mock Write-Host {}
        Show-Measurement -Data $stats
        Assert-MockCalled Write-Host -Scope It -Times 1 -Exactly
    }
    It 'Produces input object' {
        Mock Write-Host {}
        $input = Show-Measurement -Data $stats -PassThru
        $input | Should Be $stats
    }
}