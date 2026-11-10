# ==========================================================
#  Kiadas: egy uj verzio a GitHubra (GitHub Release), amit a segedlet
#  6. menupontja (Segedlet frissitese) letolt.
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
# Kulso parancs (git, gh): a hibakimenetre irt uzenet (pl. remote: ...) nem hiba - a kilepesi kod szamit
function K([string]$hiba) {
    $ErrorActionPreference = 'Continue'
    $ki = & $args[0] $args[1..($args.Count - 1)] 2>&1
    if ($LASTEXITCODE -ne 0) { $ki | ForEach-Object { Write-Host "  $_" }; Stop $hiba }
    $ki | ForEach-Object { [string]$_ } | Where-Object { $_ -and $_ -notmatch '^remote:' }
}

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
K 'a git fetch nem sikerült' git fetch -q origin --tags | Out-Null
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
K 'a git add nem sikerült' git add profil_mentes/verzio.txt README.md | Out-Null
K 'a commit nem sikerült' git commit -q -m "Kiadás $Verzio" | Out-Null
K 'a címke nem jött létre' git tag -a $cimke -m "Eszközcsere segédlet $Verzio" | Out-Null
K 'a push nem sikerült' git push -q origin $ag | Out-Null
K 'a címke pusholása nem sikerült' git push -q origin $cimke | Out-Null

# ---------- ZIP ----------
Lepes 'Csomag'
$zip = Join-Path $env:TEMP "Eszkozcsere_segedlet_$Verzio.zip"
if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
K 'a csomag nem készült el' git archive --format=zip --prefix=Eszkozcsere_segedlet/ -o $zip $cimke Eszkozcsere_segedlet.bat profil_mentes | Out-Null
'{0}  ({1:0} KB)' -f $zip, ((Get-Item -LiteralPath $zip).Length / 1KB)

# ---------- Release ----------
Lepes 'Kiadás a GitHubon'
if (-not $Leiras) { $Leiras = "Eszközcsere segédlet $Verzio" }
$arg = @('release', 'create', $cimke, $zip, '--title', "Eszközcsere segédlet $Verzio", '--notes', $Leiras)
if ($Proba) { $arg += @('--prerelease', '--latest=false') }
K 'a GitHub-kiadás nem jött létre – a címke már fent van, gh release create-tel pótolható' gh @arg
Remove-Item -LiteralPath $zip -Force
Write-Host ''
if ($Proba) { Write-Host "KÉSZ: $Verzio próbakiadás. Csak FR_KIADAS=$cimke mellett tölti le a segédlet." -ForegroundColor Green }
else { Write-Host "KÉSZ: $Verzio kiadva. A segédlet 6. menüpontja (Segédlet frissítése) mostantól ezt tölti le." -ForegroundColor Green }
