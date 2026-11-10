# ==========================================================
#  A segedlet fajljainak csereje - a ps\frissites.ps1 inditja a hatterben,
#  egy atmeneti masolatbol (a csere a ps\ mappat is atirja).
#  Bemenet (kornyezeti valtozok):
#    FC_SZULO   a segedlet cmd-jenek folyamatazonositoja - ezt megvarja
#    FC_FORRAS  az uj profil_mentes mappa (kicsomagolva)
#    FC_CEL     a segedlet mappaja - ide masol, tukrozve
#    FC_MUNKA   az atmeneti mappa - a vegen torli
#    FC_JEL     az uj valtozat azonositoja - a frissites.txt-be irja
#    FC_UJRA    0 = ne inditsa ujra a segedletet (teszthez)
#  Naplo: %TEMP%\eszkozcsere_frissites_naplo.txt
# ==========================================================
$ErrorActionPreference = 'Stop'
$naplo = Join-Path $env:TEMP 'eszkozcsere_frissites_naplo.txt'
function N($t) { Add-Content -LiteralPath $naplo -Value ((Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + '  ' + $t) -Encoding UTF8 }
function Hiba($t) {
    N "HIBA: $t"
    try {
        Add-Type -AssemblyName System.Windows.Forms
        [void][Windows.Forms.MessageBox]::Show("A segédlet frissítése nem sikerült:`n$t`n`nA régi változat megmaradt. Napló: $naplo", 'Eszközcsere segédlet', 'OK', 'Warning')
    } catch { }
    exit 1
}

N "Frissites: $($env:FC_FORRAS) -> $($env:FC_CEL)"
# 1. Megvarjuk, amig a segedlet bezarul - legfeljebb 30 percig
$sz = [int]$env:FC_SZULO
$hatar = (Get-Date).AddMinutes(30)
while ((Get-Process -Id $sz -ErrorAction SilentlyContinue) -and (Get-Date) -lt $hatar) { Start-Sleep -Milliseconds 500 }
if (Get-Process -Id $sz -ErrorAction SilentlyContinue) { Hiba 'a segédlet 30 perc után sem zárult be' }
Start-Sleep -Milliseconds 800

# 2. Biztonsag: csak akkor tukrozunk, ha a forras es a cel is a segedlet mappaja
$kell = 'Eszkozcsere_segedlet.bat', 'lib\ui.cmd', 'modulok\mentes.cmd'
foreach ($m in $env:FC_FORRAS, $env:FC_CEL) {
    if (-not $m -or @($kell | Where-Object { -not (Test-Path -LiteralPath (Join-Path $m $_)) }).Count) { Hiba "nem a segédlet mappája: $m" }
}

# 3. Csere: a cel pontosan az uj valtozat lesz - ami a GitHubon mar nincs, az torlodik
& robocopy.exe $env:FC_FORRAS $env:FC_CEL /MIR /R:3 /W:1 /NP /NFL /NDL /NJH /XF frissites.txt | Out-Null
$rc = $LASTEXITCODE
N "robocopy kilepesi kod: $rc"
if ($rc -ge 8) { Hiba "a fájlok nem másolhatók (robocopy: $rc) – nyitva van valami a segédlet mappájából?" }
[IO.File]::WriteAllText((Join-Path $env:FC_CEL 'frissites.txt'), $env:FC_JEL + "`r`n" + (Get-Date -Format 'yyyy. MM. dd. HH:mm') + "`r`n", (New-Object Text.UTF8Encoding $false))
N 'Kesz.'

# 4. Takaritas es ujrainditas
Remove-Item -LiteralPath $env:FC_MUNKA -Recurse -Force -ErrorAction SilentlyContinue
if ($env:FC_UJRA -ne '0') {
    Start-Process -FilePath 'cmd.exe' -ArgumentList ('/c "' + (Join-Path $env:FC_CEL 'Eszkozcsere_segedlet.bat') + '"') -WorkingDirectory $env:FC_CEL
}
