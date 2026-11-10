# ==========================================================
#  A segedlet frissitese a GitHubrol - lib\frissites.cmd futtatja
#  Bemenet:  FR_MOD    ELLENORIZ | LETOLT | INDIT
#            FR_REPO   pl. dan0dev/adat_mentes_kiko,  FR_AG  pl. master
#            FR_APP    a segedlet mappaja (ebben van az Eszkozcsere_segedlet.bat)
#            FR_MUNKA  ideiglenes mappa a letolteshez
#            FR_KI     eredmenyfajl
#  ELLENORIZ: a legujabb commit a GitHub API-bol, es a helyi valtozat (frissites.txt)
#             FR_KI sorai: allapot, helyi sha, uj sha, uj datum, uj uzenet
#  LETOLT:    a repo ZIP-je, kicsomagolas, a profil_mentes mappa ellenorzese
#  INDIT:     a ps\frissites_csere.ps1 elinditasa a hatterben: az megvarja, amig a
#             segedlet bezarul, csak utana cserel - futo .bat-ot nem szabad felulirni
# ==========================================================
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$fej = @{ 'User-Agent' = 'Eszkozcsere-segedlet' }
$utf8 = New-Object Text.UTF8Encoding $false

function Ki([string[]]$sorok) {
    [IO.File]::WriteAllLines($env:FR_KI, ($sorok | ForEach-Object { if ($_) { $_ } else { '-' } }), $utf8)
    exit 0
}
# A gep proxybeallitasa, a bejelentkezett felhasznalo nevevel - ceges proxy mogott is menjen
try { [Net.WebRequest]::DefaultWebProxy.Credentials = [Net.CredentialCache]::DefaultNetworkCredentials } catch { }

# ---------- Ellenorzes ----------
if ($env:FR_MOD -eq 'ELLENORIZ') {
    $helyi = ''
    $jel = Join-Path $env:FR_APP 'frissites.txt'
    if (Test-Path -LiteralPath $jel) { $helyi = ([IO.File]::ReadAllLines($jel)[0]).Trim() }
    try {
        $c = Invoke-RestMethod -UseBasicParsing -Uri "https://api.github.com/repos/$($env:FR_REPO)/commits/$($env:FR_AG)" -Headers $fej -TimeoutSec 20
    } catch {
        Ki @('HIBA', $helyi, '', '', 'Nincs kapcsolat a GitHubbal – internet vagy céges proxy/tűzfal?')
    }
    $datum = ([datetime]$c.commit.committer.date).ToLocalTime().ToString('yyyy. MM. dd. HH:mm')
    $uzenet = (($c.commit.message -split "`n")[0] -replace '["!%^&<>|]', '').Trim()
    if ($uzenet.Length -gt 50) { $uzenet = $uzenet.Substring(0, 49) + '…' }
    $allapot = 'UJ'; if ($helyi -and $helyi -eq $c.sha) { $allapot = 'AZONOS' }
    Ki @($allapot, $helyi, $c.sha, $datum, $uzenet)
}

# ---------- Letoltes ----------
if ($env:FR_MOD -eq 'LETOLT') {
    $munka = $env:FR_MUNKA
    if (Test-Path -LiteralPath $munka) { Remove-Item -LiteralPath $munka -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $munka | Out-Null
    $zip = Join-Path $munka 'segedlet.zip'
    try {
        Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/$($env:FR_REPO)/archive/refs/heads/$($env:FR_AG).zip" -OutFile $zip -Headers $fej -TimeoutSec 120
    } catch {
        Ki @('HIBA', 'nem tölthető le', 'Nincs kapcsolat a GitHubbal – internet vagy céges proxy/tűzfal?')
    }
    try { Expand-Archive -LiteralPath $zip -DestinationPath (Join-Path $munka 'ki') -Force }
    catch { Ki @('HIBA', 'a letöltött fájl hibás', 'A ZIP nem csomagolható ki.') }
    # A ZIP gyokereben egy <repo>-<ag> mappa, abban a profil_mentes
    $uj = Get-ChildItem -LiteralPath (Join-Path $munka 'ki') -Directory | ForEach-Object { Join-Path $_.FullName 'profil_mentes' } |
          Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    $kell = 'Eszkozcsere_segedlet.bat', 'lib\ui.cmd', 'lib\tetelek.cmd', 'config\tetelek.cmd', 'modulok\mentes.cmd'
    if (-not $uj -or @($kell | Where-Object { -not (Test-Path -LiteralPath (Join-Path $uj $_)) }).Count) {
        Ki @('HIBA', 'a letöltés nem teljes', 'A letöltött változatból hiányzik a segédlet egy része – nem cserélem le.')
    }
    $db = @(Get-ChildItem -LiteralPath $uj -Recurse -File).Count
    [IO.File]::WriteAllText((Join-Path $munka 'uj_mappa.txt'), $uj, $utf8)
    Ki @('OK', "$db fájl, ellenőrizve", '')
}

# ---------- Csere inditasa ----------
if ($env:FR_MOD -eq 'INDIT') {
    $uj = [IO.File]::ReadAllText((Join-Path $env:FR_MUNKA 'uj_mappa.txt')).Trim()
    # A cserelo szkript is atmeneti helyre kerul: a csere a ps\ mappat is atirja
    $csere = Join-Path $env:FR_MUNKA 'frissites_csere.ps1'
    Copy-Item -LiteralPath (Join-Path $env:FR_APP 'ps\frissites_csere.ps1') -Destination $csere -Force
    # A segedlet cmd-je: ennek a PowerShellnek a szuloje - ha bezarul, johet a csere
    $szulo = (Get-CimInstance Win32_Process -Filter "ProcessId=$PID").ParentProcessId
    $env:FC_SZULO = [string]$szulo
    $env:FC_FORRAS = $uj
    $env:FC_CEL = $env:FR_APP
    $env:FC_MUNKA = $env:FR_MUNKA
    $env:FC_JEL = $env:FR_UJ_SHA
    $env:FC_SCRIPT = $csere
    $arg = '-NoProfile -NonInteractive -WindowStyle Hidden -Command "& ([scriptblock]::Create([IO.File]::ReadAllText($env:FC_SCRIPT)))"'
    Start-Process -FilePath 'powershell.exe' -ArgumentList $arg -WindowStyle Hidden
    Ki @('OK', 'bezáráskor frissül', 'Nyomj meg egy billentyűt – a segédlet bezárul, frissül és újraindul.')
}
