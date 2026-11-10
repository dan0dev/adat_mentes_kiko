# ==========================================================
#  Helyellenorzes - lib\ellenorzes.cmd :HELY futtatja
#  Bemenet:  PS_FORRASOK - mappak pontosvesszovel elvalasztva
#            PS_BETU     - a celmeghajto, pl. E:
#            PS_KIEMELT  - egy a forrasok kozul, amirol kulon fajlszam es meret kell
#                          (az atugorhato tetel, pl. C:\TEMP) - lehet ures is
#  Kimenet egy sorban: szukseges_MB szabad_MB fajlrendszer legnagyobb_fajl_MB
#                      kiemelt_fajlszam kiemelt_meret
#  A kiemelt fajlszam - , ha nincs ilyen mappa; a meret szoveg, pl. 2,1 GB vagy 350 MB.
#  Kilepesi kod 1, ha a meghajto nem talalhato.
# ==========================================================
$s = 0; $m = 0
$kdb = '-'; $kb = 0
foreach ($x in ($env:PS_FORRASOK -split ';')) {
    if ($x -and (Test-Path -LiteralPath $x)) {
        $kiemelt = $env:PS_KIEMELT -and ($x -eq $env:PS_KIEMELT)
        $db = 0; $b = 0
        Get-ChildItem -LiteralPath $x -Recurse -File -Force -ErrorAction SilentlyContinue |
            ForEach-Object { $db++; $b += $_.Length; if ($_.Length -gt $m) { $m = $_.Length } }
        $s += $b
        if ($kiemelt) { $kdb = $db; $kb = $b }
    }
}
if ($kb -lt 1MB) { $kmeret = '1 MB alatt' }
elseif ($kb -lt 1GB) { $kmeret = [string][long][math]::Ceiling($kb / 1MB) + ' MB' }
else { $kmeret = ('{0:0.0}' -f ($kb / 1GB)).Replace('.', ',') + ' GB' }
$d = Get-CimInstance Win32_LogicalDisk | Where-Object DeviceID -eq $env:PS_BETU
if (-not $d) { exit 1 }
[string]([long]($s / 1MB) + 1) + ' ' + [string]([long]($d.FreeSpace / 1MB)) + ' ' + $d.FileSystem + ' ' + [string]([long]($m / 1MB)) + ' ' + $kdb + ' ' + $kmeret
