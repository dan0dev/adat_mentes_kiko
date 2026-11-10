# ==========================================================
#  A segedlet frissitese a GitHubrol, kiadasbol - lib\frissites.cmd futtatja
#  Bemenet:  FR_MOD      ELLENORIZ | LETOLT | INDIT
#            FR_REPO     pl. dan0dev/adat_mentes_kiko
#            FR_KIADAS   ures = a legutolso kiadas, kulonben ez a cimke (pl. v1.2) - teszthez
#            VERZIO      a futo valtozat (verzio.txt)
#            FR_APP      a segedlet mappaja (profil_mentes, benne a segedlet.bat)
#            FR_MUNKA    ideiglenes mappa a letolteshez
#            FR_UJ_URL, FR_UJ_VERZIO  letolteskor: az ELLENORIZ eredmenye
#            FR_KI       eredmenyfajl
#  ELLENORIZ: a kiadas a GitHub API-bol. FR_KI sorai: allapot (UJ, AZONOS, HIBA), helyi verzio,
#             uj verzio, datum, leiras, a ZIP cime
#  LETOLT:    a kiadas ZIP-je, kicsomagolas, a profil_mentes mappa es a verzio ellenorzese
#  INDIT:     a ps\frissites_csere.ps1 elinditasa a hatterben: az megvarja, amig a
#             segedlet bezarul, csak utana cserel - futo .bat-ot nem szabad felulirni
# ==========================================================
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$fej = @{ 'User-Agent' = 'Eszkozcsere-segedlet' }
$utf8 = New-Object Text.UTF8Encoding $false
$NINCS_NET = 'Nincs kapcsolat a GitHubbal – internet vagy céges proxy/tűzfal?'

function Ki([string[]]$sorok) {
    [IO.File]::WriteAllLines($env:FR_KI, ($sorok | ForEach-Object { if ($_) { $_ } else { '-' } }), $utf8)
    exit 0
}
function Tiszta($t) { (($t -split "`n")[0] -replace '["!%^&<>|]', '').Trim() }
# A gep proxybeallitasa, a bejelentkezett felhasznalo nevevel - ceges proxy mogott is menjen
try { [Net.WebRequest]::DefaultWebProxy.Credentials = [Net.CredentialCache]::DefaultNetworkCredentials } catch { }

# ---------- Ellenorzes ----------
if ($env:FR_MOD -eq 'ELLENORIZ') {
    $helyi = $env:VERZIO
    $url = "https://api.github.com/repos/$($env:FR_REPO)/releases/latest"
    if ($env:FR_KIADAS) { $url = "https://api.github.com/repos/$($env:FR_REPO)/releases/tags/$($env:FR_KIADAS)" }
    try {
        $r = Invoke-RestMethod -UseBasicParsing -Uri $url -Headers $fej -TimeoutSec 20
    } catch {
        $kod = 0; try { $kod = [int]$_.Exception.Response.StatusCode } catch { }
        if ($kod -eq 404) { Ki @('HIBA', $helyi, '', '', 'Még nincs kiadás a GitHubon.') }
        Ki @('HIBA', $helyi, '', '', $NINCS_NET)
    }
    $uj = ([string]$r.tag_name).TrimStart('v', 'V')
    $zip = @($r.assets | Where-Object { $_.name -like '*.zip' }) | Select-Object -First 1
    if (-not $zip) { Ki @('HIBA', $helyi, $uj, '', 'A kiadásban nincs letölthető csomag.') }
    $datum = ([datetime]$r.published_at).ToLocalTime().ToString('yyyy. MM. dd.')
    $leiras = Tiszta $r.body
    if (-not $leiras) { $leiras = Tiszta $r.name }
    if ($leiras.Length -gt 50) { $leiras = $leiras.Substring(0, 49) + '…' }
    # Verzioszamok osszevetese: csak ujabbra frissit
    $allapot = 'UJ'
    try { if ([version]$uj -le [version]$helyi) { $allapot = 'AZONOS' } }
    catch { if ($uj -eq $helyi) { $allapot = 'AZONOS' } }
    Ki @($allapot, $helyi, $uj, $datum, $leiras, $zip.browser_download_url)
}

# ---------- Letoltes ----------
if ($env:FR_MOD -eq 'LETOLT') {
    $munka = $env:FR_MUNKA
    if (Test-Path -LiteralPath $munka) { Remove-Item -LiteralPath $munka -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $munka | Out-Null
    $zip = Join-Path $munka 'segedlet.zip'
    try {
        Invoke-WebRequest -UseBasicParsing -Uri $env:FR_UJ_URL -OutFile $zip -Headers $fej -TimeoutSec 120
    } catch {
        Ki @('HIBA', 'nem tölthető le', $NINCS_NET)
    }
    try { Expand-Archive -LiteralPath $zip -DestinationPath (Join-Path $munka 'ki') -Force }
    catch { Ki @('HIBA', 'a letöltött fájl hibás', 'A ZIP nem csomagolható ki.') }
    # A ZIP-ben valahol egy profil_mentes mappa, benne a segedlet.bat
    $uj = Get-ChildItem -LiteralPath (Join-Path $munka 'ki') -Directory -Recurse -Filter 'profil_mentes' |
          Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'segedlet.bat') } | Select-Object -First 1 -ExpandProperty FullName
    $kell = 'segedlet.bat', 'verzio.txt', 'lib\ui.cmd', 'lib\tetelek.cmd', 'config\tetelek.cmd', 'modulok\mentes.cmd'
    if (-not $uj -or @($kell | Where-Object { -not (Test-Path -LiteralPath (Join-Path $uj $_)) }).Count) {
        Ki @('HIBA', 'a letöltés nem teljes', 'A letöltött változatból hiányzik a segédlet egy része – nem cserélem le.')
    }
    $v = ([IO.File]::ReadAllLines((Join-Path $uj 'verzio.txt'))[0]).Trim()
    if ($v -ne $env:FR_UJ_VERZIO) { Ki @('HIBA', 'a verzió nem egyezik', "A csomagban $v van, a kiadás $($env:FR_UJ_VERZIO) – nem cserélem le.") }
    $db = @(Get-ChildItem -LiteralPath $uj -Recurse -File).Count
    [IO.File]::WriteAllText((Join-Path $munka 'uj_mappa.txt'), $uj, $utf8)
    Ki @('OK', "$db fájl, ellenőrizve", "Verzió: $v")
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
    $env:FC_SCRIPT = $csere
    $arg = '-NoProfile -NonInteractive -WindowStyle Hidden -Command "& ([scriptblock]::Create([IO.File]::ReadAllText($env:FC_SCRIPT)))"'
    Start-Process -FilePath 'powershell.exe' -ArgumentList $arg -WindowStyle Hidden
    Ki @('OK', 'bezáráskor frissül', 'Nyomj meg egy billentyűt – a segédlet bezárul, frissül és újraindul.')
}
