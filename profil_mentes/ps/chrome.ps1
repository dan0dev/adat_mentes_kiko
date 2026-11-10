# ==========================================================
#  Chrome telepitese - lib\chrome.cmd futtatja
#  A Google hivatalos ceges telepitoje (MSI), mindig a legfrissebb verzio.
#  Bemenet:  CHROME_MOD  VERZIO | LETOLT | TELEPIT
#            CHROME_KI   eredmenyfajl: 1. allapot, 2. uzenet, 3. reszlet (- ha nincs)
#            CHROME_MSI  a letoltott telepito helye
#            CHROME_NAPLO  a telepito (msiexec) naplofajlja
#  VERZIO: a telepitett Chrome verzioja a kimenetre, vagy - ha nincs
#  LETOLT: BITS-szel (a gep proxybeallitasaval), ha az nem megy, curl-lel; utana
#          alairas-ellenorzes: csak ervenyes, Google LLC altal alairt fajl maradhat
#  TELEPIT: msiexec rendszergazdakent - a Windows keri a jelszot -, csendben, utana
#           a telepitett verzio ellenorzese, a telepito torlese
# ==========================================================
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$URL = 'https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi'
$behuz = '           '
$szurke = $env:C_SZURKE; $nulla = $env:C_0

function Ki($allapot, $uzenet, $reszlet) {
    if (-not $reszlet) { $reszlet = '-' }
    [IO.File]::WriteAllLines($env:CHROME_KI, [string[]]@($allapot, $uzenet, $reszlet), (New-Object Text.UTF8Encoding $false))
    exit 0
}
function Verzio {
    foreach ($k in 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe',
                   'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe') {
        $ut = (Get-ItemProperty -Path $k -ErrorAction SilentlyContinue).'(default)'
        if ($ut -and (Test-Path -LiteralPath $ut)) { return (Get-Item -LiteralPath $ut).VersionInfo.ProductVersion }
    }
    return $null
}
function Sor($szoveg) { [Console]::Write("`r" + $behuz + $szurke + $szoveg.PadRight(40) + $nulla) }

# ---------- Verzio ----------
if ($env:CHROME_MOD -eq 'VERZIO') {
    $v = Verzio
    if ($v) { $v } else { '-' }
    exit 0
}

# ---------- Letoltes ----------
if ($env:CHROME_MOD -eq 'LETOLT') {
    $msi = $env:CHROME_MSI
    New-Item -ItemType Directory -Force -Path (Split-Path $msi) | Out-Null
    if (Test-Path -LiteralPath $msi) { Remove-Item -LiteralPath $msi -Force }
    $mod = ''
    # 1. BITS: a Windows letoltoszolgaltatasa, a gep proxybeallitasaval
    try {
        Import-Module BitsTransfer -ErrorAction Stop
        $job = Start-BitsTransfer -Source $URL -Destination $msi -Asynchronous -Priority Foreground -DisplayName 'Eszkozcsere segedlet - Chrome'
        $hibaota = $null
        while ($job.JobState -in 'Queued', 'Connecting', 'Transferring', 'TransientError') {
            if ($job.JobState -eq 'TransientError') {
                if (-not $hibaota) { $hibaota = Get-Date } elseif (((Get-Date) - $hibaota).TotalSeconds -gt 20) { break }
            } else { $hibaota = $null }
            if ($job.BytesTotal -gt 0 -and $job.BytesTotal -lt [uint64]::MaxValue) {
                Sor ('{0,3}%   {1} / {2} MB' -f [int](100 * $job.BytesTransferred / $job.BytesTotal), [int]($job.BytesTransferred / 1MB), [int]($job.BytesTotal / 1MB))
            } else { Sor 'kapcsolódás...' }
            Start-Sleep -Milliseconds 400
        }
        if ($job.JobState -eq 'Transferred') { Complete-BitsTransfer -BitsJob $job; $mod = 'BITS' }
        else { Remove-BitsTransfer -BitsJob $job -ErrorAction SilentlyContinue }
    } catch { }
    [Console]::Write("`r" + (' ' * 60) + "`r")
    # 2. Ha a BITS nem ment: a Windows sajat curl-je
    if (-not $mod) {
        $curl = Join-Path $env:SystemRoot 'System32\curl.exe'
        if (Test-Path -LiteralPath $curl) {
            [Console]::WriteLine($behuz + $szurke + 'második próba...' + $nulla)
            & $curl --fail --location --silent --show-error --connect-timeout 20 --max-time 1800 --output $msi $URL 2>$null
            if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $msi)) { $mod = 'curl' }
        }
    }
    if (-not $mod -or -not (Test-Path -LiteralPath $msi)) {
        Ki 'HIBA' 'nem tölthető le' 'Nincs kapcsolat a dl.google.com-mal – internet vagy céges proxy/tűzfal?'
    }
    $mb = [int]((Get-Item -LiteralPath $msi).Length / 1MB)
    # Alairas: csak a Google ervenyes alairasaval futhat
    $s = Get-AuthenticodeSignature -LiteralPath $msi
    if ($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch '^CN=Google LLC,') {
        Remove-Item -LiteralPath $msi -Force -ErrorAction SilentlyContinue
        Ki 'HIBA' 'az aláírás nem megfelelő' ('A letöltött fájl nem a Google érvényes aláírásával érkezett (' + $s.Status + ') – törölve.')
    }
    Ki 'OK' "$mb MB, Google-aláírás rendben" ''
}

# ---------- Telepites ----------
if ($env:CHROME_MOD -eq 'TELEPIT') {
    $msi = $env:CHROME_MSI
    if (-not (Test-Path -LiteralPath $msi)) { Ki 'HIBA' 'nincs letöltött telepítő' '' }
    $regi = Verzio
    [Console]::WriteLine($behuz + $szurke + 'A Windows most kéri a rendszergazdai jelszót...' + $nulla)
    try {
        $arg = '/i "' + $msi + '" /qn /norestart /L*v "' + $env:CHROME_NAPLO + '"'
        $p = Start-Process -FilePath (Join-Path $env:SystemRoot 'System32\msiexec.exe') -ArgumentList $arg -Verb RunAs -Wait -PassThru
    } catch {
        Remove-Item -LiteralPath $msi -Force -ErrorAction SilentlyContinue
        Ki 'KIHAGYVA' 'nem kaptam rendszergazdai jogot' 'A jelszókérő ablakot bezárták – a Chrome nem települt.'
    }
    $kod = $p.ExitCode
    Remove-Item -LiteralPath $msi -Force -ErrorAction SilentlyContinue
    $uj = Verzio
    if ($kod -in 0, 3010, 1641) {
        if (-not $uj) { Ki 'HIBA' 'a Chrome nem található' ('A telepítő sikert jelzett, de a chrome.exe nincs meg. Napló: ' + $env:CHROME_NAPLO) }
        $r = ''
        if ($regi -and $regi -eq $uj) { $r = 'Ez a verzió volt fent korábban is.' } elseif ($regi) { $r = "Korábban: $regi" }
        if ($kod -ne 0) { $r = ($r + ' Újraindítás után lesz teljes.').Trim() }
        Ki 'OK' "Chrome $uj" $r
    }
    $ok = switch ($kod) {
        1602 { 'a telepítést megszakították' }
        1618 { 'épp fut egy másik telepítés – próbáld újra pár perc múlva' }
        1638 { 'másik Chrome-telepítés van a gépen – az Alkalmazásokban távolítsd el, majd próbáld újra' }
        default { 'részletek a naplóban: ' + $env:CHROME_NAPLO }
    }
    Ki 'HIBA' "sikertelen telepítés (kód: $kod)" $ok
}
