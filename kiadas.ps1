# ==========================================================
#  Kiadas: egy uj verzio a GitHubra (GitHub Release), amit a segedlet
#  5. menupontja letolt.
#
#    .\kiadas.ps1 1.1 "Chrome telepítése, BitLocker, frissítés"
#
#  Lepesek: tesztek -> verzio.txt -> commit, cimke (v1.1), push -> ZIP -> Release.
#  A ZIP a cimkezett, commitolt allapotbol keszul: Eszkozcsere_segedlet.bat (indito)
#  es a profil_mentes mappa - tesztek, dokumentacio es git-elozmeny nelkul.
#
#  -TesztNelkul  a tesztek kihagyasa (csak ha tudod, mit csinalsz)
#  -Proba        probakiadas: nem a master-rol is mehet, es nem lesz "legutolso"
#                kiadas - a segedlet csak akkor tolti le, ha FR_KIADAS erre a cimkere mutat
# ==========================================================
param(
    [Parameter(Mandatory)][string]$Verzio,
    [string]$Leiras = '',
    [switch]$TesztNelkul,
    [switch]$Proba
)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
function Lepes($t) { Write-Host ''; Write-Host "== $t" -ForegroundColor Cyan }
function Stop($t) { Write-Host ''; Write-Host "MEGÁLLTAM: $t" -ForegroundColor Red; exit 1 }

# ---------- Ellenorzesek ----------
Lepes 'Ellenőrzés'
if ($Verzio -notmatch '^\d+\.\d+(\.\d+)?$') { Stop "a verzió formája: 1.1 vagy 1.1.2 – ez nem jó: $Verzio" }
$cimke = "v$Verzio"
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Stop 'nincs gh (GitHub CLI) – telepítsd, és jelentkezz be: gh auth login' }
gh auth status *> $null
if ($LASTEXITCODE -ne 0) { Stop 'a gh nincs bejelentkezve – gh auth login' }
$ag = (git rev-parse --abbrev-ref HEAD).Trim()
if (-not $Proba -and $ag -ne 'master') { Stop "a kiadás a master ágról megy – most ezen vagy: $ag" }
if (git status --porcelain) { Stop 'van nem commitolt változás – előbb commitold vagy dobd el' }
git fetch -q origin --tags
if (git tag --list $cimke) { Stop "már van ilyen kiadás/címke: $cimke" }
$regi = ([IO.File]::ReadAllLines((Join-Path $PSScriptRoot 'profil_mentes\verzio.txt'))[0]).Trim()
if (-not $Proba -and ([version]$Verzio -le [version]$regi)) { Stop "az új verzió ($Verzio) nem nagyobb a mostaninál ($regi)" }
"Verzió: $regi -> $Verzio   ág: $ag   címke: $cimke"

# ---------- Tesztek ----------
if (-not $TesztNelkul) {
    Lepes 'Tesztek'
    & (Join-Path $PSScriptRoot 'tesztkornyezet\mind.ps1') -Ellenoriz -Kredit -Szoveg
    if ($LASTEXITCODE -ne 0) { Stop 'nem minden teszt ment át – a kiadás nem készült el' }
    if (git status --porcelain) { Stop 'a tesztek után változott egy commitolt fájl – nézd meg: git status' }
}

# ---------- Verzio, commit, cimke ----------
Lepes 'Verzió, commit, címke'
$utf8 = New-Object Text.UTF8Encoding $false
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'profil_mentes\verzio.txt'), "$Verzio`r`n", $utf8)
$readme = Join-Path $PSScriptRoot 'README.md'
$r = [IO.File]::ReadAllText($readme, [Text.Encoding]::UTF8) -replace '\*\*Verzió: [0-9.]+\*\*', "**Verzió: $Verzio**"
[IO.File]::WriteAllText($readme, $r, $utf8)
git add profil_mentes/verzio.txt README.md
git commit -q -m "Kiadás $Verzio"
git tag -a $cimke -m "Eszközcsere segédlet $Verzio"
git push -q origin $ag
git push -q origin $cimke
if ($LASTEXITCODE -ne 0) { Stop 'a push nem sikerült' }

# ---------- ZIP ----------
Lepes 'Csomag'
$zip = Join-Path $env:TEMP "Eszkozcsere_segedlet_$Verzio.zip"
if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
git archive --format=zip --prefix=Eszkozcsere_segedlet/ -o $zip $cimke Eszkozcsere_segedlet.bat profil_mentes
'{0}  ({1:0} KB)' -f $zip, ((Get-Item -LiteralPath $zip).Length / 1KB)

# ---------- Release ----------
Lepes 'Kiadás a GitHubon'
if (-not $Leiras) { $Leiras = "Eszközcsere segédlet $Verzio" }
$arg = @('release', 'create', $cimke, $zip, '--title', "Eszközcsere segédlet $Verzio", '--notes', $Leiras)
if ($Proba) { $arg += @('--prerelease', '--latest=false') }
gh @arg
if ($LASTEXITCODE -ne 0) { Stop 'a GitHub-kiadás nem jött létre – a címke már fent van, gh release create-tel pótolható' }
Remove-Item -LiteralPath $zip -Force
Write-Host ''
Write-Host "KÉSZ: $Verzio kiadva. A segédlet 5. menüpontja mostantól ezt tölti le." -ForegroundColor Green
