# ==========================================================
#  Az osszegzes szamai es a mentes fajljai JSON-ban - az alap\ fajlokkal
#  osszehasonlithato, igy latszik, ha a viselkedes megvaltozott.
#  -Atirat   a futtat.ps1 altal irt UTF-8 atirat
#  -Mentes   a mentes mappa; a fajlnevek a regi es az uj nevekrol kozos nevre kerulnek
# ==========================================================
param(
    [Parameter(Mandatory)][string]$Atirat,
    [string]$Mentes
)
$ErrorActionPreference = 'Stop'
$tiszta = [regex]::Replace([IO.File]::ReadAllText($Atirat, [Text.Encoding]::UTF8), [string][char]27 + '\[[0-9;]*m', '')
$m = [regex]::Match($tiszta, '(Sikeres|Rendben):\s*(\d+)\D+(Hib\S*|Probl\S*):\s*(\d+)\D+Kihagyva:\s*(\d+)')
$ki = [ordered]@{ sikeres = -1; hibas = -1; kihagyva = -1; fajlok = @() }
if ($m.Success) { $ki.sikeres = [int]$m.Groups[2].Value; $ki.hibas = [int]$m.Groups[4].Value; $ki.kihagyva = [int]$m.Groups[5].Value }
if ($Mentes -and (Test-Path -LiteralPath $Mentes)) {
    $gy = (Resolve-Path -LiteralPath $Mentes).Path.TrimEnd('\') + '\'
    $ki.fajlok = @(Get-ChildItem -LiteralPath $Mentes -Recurse -File -Force | ForEach-Object {
        $r = $_.FullName.Substring($gy.Length)
        $r = $r -replace '_LEFT-TO-DO\.txt$', '_TEENDOK.txt' -replace '_log\.txt$', '_naplo.txt' -replace '^teszt_', 'probafuttatas_'
        $r = $r -replace '^_MENTES_.*\.txt$', '_MENTES.txt' -replace '^_(EXPORT|VISSZAALLITAS)_.*\.txt$', '_VISSZAALLITAS.txt'
        # A tanusitvanyfajlok neve az ujjlenyomat - minden futasnal mas
        $r = $r -replace '^(Tanusitvanyok\\[^\\]+\\)[0-9A-F]{40}\.(pfx|cer)$', '$1X.$2'
        $r
    } | Sort-Object -Unique)
}
$ki | ConvertTo-Json -Compress
