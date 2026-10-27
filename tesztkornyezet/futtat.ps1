# ==========================================================
#  A segedlet futtatasa hamis profillal, hamis kulso meghajtoval,
#  elore megirt valaszokkal. Kimenet: kimenet\<Valaszok>.txt (UTF-8 atirat)
#
#  -Valaszok      a valaszok\<nev>.txt fajl neve kiterjesztes nelkul
#  -Mentes        egy kesz mentes mappa, ezt masolja a hamis meghajtora, es ezt valasztja ki
#  -Kodlap        a konzol kodlapja a futtatas elott, mint dupla kattintasnal (852); 0 = nem valt
#  -AtiratKodlap  ezen a kodlapon olvassa vissza az atiratot (regi verzio: 852)
#  -Tiszta        a hamis meghajto kiuritese elotte
#
#  Helyettesitok a valaszfajlban: {BETU} = a hamis meghajto betuje,
#  {MENTES} = a kivalasztando mentes sorszama a listaban.
# ==========================================================
param(
    [Parameter(Mandatory)][string]$Valaszok,
    [string]$Mentes,
    [int]$Kodlap = 852,
    [int]$AtiratKodlap = 65001,
    [switch]$Tiszta
)
$ErrorActionPreference = 'Stop'
$itt = $PSScriptRoot
$bat = Join-Path (Split-Path $itt) 'profil_mentes\Eszkozcsere_segedlet.bat'
$valaszFajl = Join-Path $itt "valaszok\$Valaszok.txt"
if (-not (Test-Path -LiteralPath $valaszFajl)) { throw "Nincs ilyen valaszfajl: $valaszFajl" }

$alap = Join-Path $env:TEMP 'pm_teszt'
$profil = "$alap\profil"; $kulso = "$alap\kulso"; $tmp = "$alap\tmp"
if ($Tiszta -and (Test-Path $kulso)) { Remove-Item -LiteralPath $kulso -Recurse -Force }
foreach ($d in $profil, $kulso, $tmp) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
if (-not (Test-Path "$profil\PST")) { & "$itt\profil_feltolt.ps1" -Cel $profil | Out-Null }
New-Item -ItemType Directory -Force -Path "$itt\kimenet" | Out-Null

$ctemp = "$env:SystemDrive\TEMP"
if (Test-Path $ctemp) {
    $mb = (Get-ChildItem -LiteralPath $ctemp -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB
    if ($mb -gt 1024) { Write-Warning ("A valodi {0} {1:0} MB - a mentes ezt is olvassa, lassu lesz." -f $ctemp, $mb) }
}

$mentesGyoker = "$kulso\Mentes"
$kivalasztott = $null
if ($Mentes) {
    if (-not (Test-Path -LiteralPath $Mentes)) { throw "Nincs ilyen mentes: $Mentes" }
    $nev = Split-Path $Mentes -Leaf
    New-Item -ItemType Directory -Force -Path $mentesGyoker | Out-Null
    if (Test-Path "$mentesGyoker\$nev") { Remove-Item -LiteralPath "$mentesGyoker\$nev" -Recurse -Force }
    Copy-Item -LiteralPath $Mentes -Destination "$mentesGyoker\$nev" -Recurse
    $kivalasztott = $nev
}

# A mentes sorszama a listaban: a for /d betu szerinti sorrendben adja a mappakat
$mentesSzam = 1
if (Test-Path $mentesGyoker) {
    $lista = @(Get-ChildItem -LiteralPath $mentesGyoker -Directory | Sort-Object Name)
    for ($i = 0; $i -lt $lista.Count; $i++) {
        $n = $lista[$i].Name
        if (($kivalasztott -and $n -eq $kivalasztott) -or (-not $kivalasztott -and $n -like "$($env:USERNAME)_*")) { $mentesSzam = $i + 1; $kivalasztott = $n; break }
    }
    # Visszaallitasnal a C:\TEMP tetel soha ne irjon a valodi gepre
    if ($kivalasztott -and (Test-Path "$mentesGyoker\$kivalasztott\C_TEMP")) { Remove-Item -LiteralPath "$mentesGyoker\$kivalasztott\C_TEMP" -Recurse -Force }
}

$betu = 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' | Where-Object { -not (Test-Path "${_}:\") } | Select-Object -First 1
if (-not $betu) { throw 'Nincs szabad meghajtobetu T-Z kozott.' }
subst "${betu}:" $kulso | Out-Null

$sorok = (Get-Content -LiteralPath $valaszFajl -Encoding UTF8) -replace '\{BETU\}', $betu -replace '\{MENTES\}', $mentesSzam
$beFajl = "$tmp\_valaszok.txt"
[IO.File]::WriteAllText($beFajl, (($sorok -join "`r`n") + "`r`n"), [Text.Encoding]::ASCII)
$kiFajl = "$tmp\_atirat.bin"

# Tiszta Windows PATH: Git Bash-bol inditva a find es a sort a GNU valtozat lenne,
# a segedlet pedig a Windows sajat find.exe-jere es sort.exe-jere szamit.
$tisztaPath = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
$regi = @{}
$uj = @{ USERPROFILE = $profil; APPDATA = "$profil\AppData\Roaming"; LOCALAPPDATA = "$profil\AppData\Local"
         TEMP = $tmp; TMP = $tmp; VALASZ_SORBOL = '1'; PM_TESZT_KONFIG = "$itt\teszt_konfig.cmd"; Path = $tisztaPath }
try {
    foreach ($k in $uj.Keys) { $regi[$k] = [Environment]::GetEnvironmentVariable($k); [Environment]::SetEnvironmentVariable($k, $uj[$k]) }
    # A bemenetet a cmd sajat < atiranyitasa adja: a set /p igy soronkent olvas.
    # Csovon (Start-Process -RedirectStandardInput) egy egesz puffert elnyelne.
    $p = Start-Process -FilePath "$env:ComSpec" -WorkingDirectory (Split-Path $bat) -NoNewWindow -PassThru `
        -ArgumentList "/c `"`"$itt\_futtat.cmd`" $Kodlap `"$bat`" < `"$beFajl`" > `"$kiFajl`" 2>&1`""
    if (-not $p.WaitForExit(600000)) { $p.Kill(); Write-Warning 'Idotullepes: 10 perc utan leallitva.' }
}
finally {
    foreach ($k in $regi.Keys) { [Environment]::SetEnvironmentVariable($k, $regi[$k]) }
    subst "${betu}:" /d | Out-Null
}

$szoveg = [Text.Encoding]::GetEncoding($AtiratKodlap).GetString([IO.File]::ReadAllBytes($kiFajl))
$atirat = "$itt\kimenet\$Valaszok.txt"
[IO.File]::WriteAllText($atirat, $szoveg, (New-Object Text.UTF8Encoding $false))
$atirat
