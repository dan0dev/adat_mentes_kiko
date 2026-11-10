# ==========================================================
#  A segedlet fajljainak csereje - a ps\frissites.ps1 inditja a hatterben,
#  egy atmeneti masolatbol (a csere a ps\ mappat is atirja).
#  Bemenet (kornyezeti valtozok):
#    FC_SZULO   a segedlet cmd-jenek folyamatazonositoja - ezt megvarja
#    FC_FORRAS  az uj profil_mentes mappa (kicsomagolva)
#    FC_CEL     a segedlet mappaja - ide masol, tukrozve
#    FC_MUNKA   az atmeneti mappa - a vegen torli
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
$kell = 'segedlet.bat', 'lib\ui.cmd', 'modulok\mentes.cmd'
foreach ($m in $env:FC_FORRAS, $env:FC_CEL) {
    if (-not $m -or @($kell | Where-Object { -not (Test-Path -LiteralPath (Join-Path $m $_)) }).Count) { Hiba "nem a segédlet mappája: $m" }
}

# 3. Csere: a cel pontosan az uj valtozat lesz - ami a GitHubon mar nincs, az torlodik
& robocopy.exe $env:FC_FORRAS $env:FC_CEL /MIR /R:3 /W:1 /NP /NFL /NDL /NJH | Out-Null
$rc = $LASTEXITCODE
N "robocopy kilepesi kod: $rc"
if ($rc -ge 8) { Hiba "a fájlok nem másolhatók (robocopy: $rc) – nyitva van valami a segédlet mappájából?" }
N 'Kesz.'

# 4. Takaritas es ujrainditas
Remove-Item -LiteralPath $env:FC_MUNKA -Recurse -Force -ErrorAction SilentlyContinue
# A kulso indito (a profil_mentes mellett) indul, ha megvan - kulonben a segedlet.bat
if ($env:FC_UJRA -ne '0') {
    # Az uj ablak tiszta kornyezettel induljon - az automatikus valaszadas ne oroklodjon
    foreach ($v in 'VALASZ_SORBOL', 'PM_TESZT_KONFIG') { Remove-Item -LiteralPath "Env:$v" -ErrorAction SilentlyContinue }
    $kulso = Split-Path -Parent $env:FC_CEL
    $indito = Join-Path $kulso 'Eszkozcsere_segedlet.bat'
    if (-not (Test-Path -LiteralPath $indito)) { $indito = Join-Path $env:FC_CEL 'segedlet.bat'; $kulso = $env:FC_CEL }
    Start-Process -FilePath 'cmd.exe' -ArgumentList ('/c "' + $indito + '"') -WorkingDirectory $kulso
}
