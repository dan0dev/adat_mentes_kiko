# ==========================================================
#  Helyellenorzes - lib\ellenorzes.cmd :HELY futtatja
#  Bemenet:  PS_FORRASOK - mappak pontosvesszovel elvalasztva
#            PS_BETU     - a celmeghajto, pl. E:
#  Kimenet egy sorban: szukseges_MB szabad_MB fajlrendszer legnagyobb_fajl_MB
#  Kilepesi kod 1, ha a meghajto nem talalhato.
# ==========================================================
$s = 0; $m = 0
foreach ($x in ($env:PS_FORRASOK -split ';')) {
    if ($x -and (Test-Path -LiteralPath $x)) {
        Get-ChildItem -LiteralPath $x -Recurse -File -Force -ErrorAction SilentlyContinue |
            ForEach-Object { $s += $_.Length; if ($_.Length -gt $m) { $m = $_.Length } }
    }
}
$d = Get-CimInstance Win32_LogicalDisk | Where-Object DeviceID -eq $env:PS_BETU
if (-not $d) { exit 1 }
[string]([long]($s / 1MB) + 1) + ' ' + [string]([long]($d.FreeSpace / 1MB)) + ' ' + $d.FileSystem + ' ' + [string]([long]($m / 1MB))
