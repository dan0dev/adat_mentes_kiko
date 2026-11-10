# ==========================================================
#  Halozati teszt - lib\eszkozok.cmd :PING futtatja
#  Lepesrol lepesre: a gep IP-cime, a router (alapertelmezett atjaro), a nevfeloldas
#  (DNS), a 8.8.8.8, a google.com 10 pinggel, es egy valodi weblekeres - sok ceges
#  halozaton a ping tiltva van, a web viszont megy. A vegen egy mondatban az eredmeny.
#  Bemenet:  HT_NAPLO - a naplofajl, ehhez fuzi hozza az eredmenyt; C_* szinek
# ==========================================================
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$zold = $env:C_ZOLD; $piros = $env:C_PIROS; $sarga = $env:C_SARGA; $szurke = $env:C_SZURKE; $feher = $env:C_FEHER; $nulla = $env:C_0
$naplo = New-Object Collections.Generic.List[string]
$naplo.Add('===== ' + (Get-Date -Format 'yyyy. MM. dd. HH:mm:ss') + ' · ' + $env:COMPUTERNAME + ' · ' + $env:USERNAME + ' =====')

function Jel($allapot) {
    switch ($allapot) {
        'OK' { return $zold + '[   OK   ]' + $nulla }
        'HIBA' { return $piros + '[  HIBA  ]' + $nulla }
        default { return $sarga + '[FIGYELEM]' + $nulla }
    }
}
function Sor($allapot, $nev, $reszlet) {
    [Console]::WriteLine('  ' + (Jel $allapot) + '  ' + $nev.PadRight(18) + $reszlet)
    $naplo.Add(('  [{0}] {1} {2}' -f $allapot, $nev.PadRight(18), $reszlet))
}
function Info($nev, $ertek) {
    [Console]::WriteLine('     ' + $nev.PadRight(16) + $feher + $ertek + $nulla)
    $naplo.Add('  ' + $nev.PadRight(16) + $ertek)
}
function Pingel($cel, $db) {
    $p = New-Object Net.NetworkInformation.Ping
    $idok = @()
    for ($i = 0; $i -lt $db; $i++) {
        try { $v = $p.Send($cel, 2000); if ($v.Status -eq 'Success') { $idok += [int]$v.RoundtripTime } } catch { }
        if ($db -gt 1) { Start-Sleep -Milliseconds 200 }
    }
    return , $idok
}
# A varakozas jelzese csak a kepernyon - fajlba iranyitva (teszt) nem kell
$kepernyo = -not [Console]::IsOutputRedirected
function Varj($szoveg) { if ($kepernyo) { [Console]::Write('  ' + $szurke + $szoveg + $nulla + "`r") } }
function Torol { if ($kepernyo) { [Console]::Write((' ' * 70) + "`r") } }

# ---------- A gep halozata ----------
$cfg = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=TRUE' |
       Where-Object { $_.DefaultIPGateway } | Select-Object -First 1
$ip = $null; $atjaro = $null; $kartya = $null
if ($cfg) {
    $ip = @($cfg.IPAddress | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' })[0]
    $atjaro = @($cfg.DefaultIPGateway | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' })[0]
    $kartya = (Get-CimInstance Win32_NetworkAdapter -Filter "Index=$($cfg.Index)").NetConnectionID
}
if ($ip) { Info 'IP-cím' ("$ip" + $(if ($kartya) { "  ($kartya)" })) } else { Info 'IP-cím' 'nincs' }
if ($cfg -and $cfg.DNSServerSearchOrder) { Info 'DNS-szerver' (($cfg.DNSServerSearchOrder | Select-Object -First 2) -join ', ') }
[Console]::WriteLine('')

$e = @{}
# 1. Router
if ($atjaro) {
    Varj "Router ($atjaro)..."
    $t = Pingel $atjaro 3; Torol
    if ($t.Count) { Sor 'OK' 'Router' "$atjaro – $([int]($t | Measure-Object -Average).Average) ms"; $e.router = $true }
    else { Sor 'FIGYELEM' 'Router' "$atjaro – nem válaszol a pingre"; $e.router = $false }
} else { Sor 'HIBA' 'Router' 'nincs alapértelmezett átjáró'; $e.router = $false; $e.nincsatjaro = $true }

# 2. Nevfeloldas
Varj 'Névfeloldás (google.com)...'
$sw = [Diagnostics.Stopwatch]::StartNew()
$cimek = $null; try { $cimek = [Net.Dns]::GetHostAddresses('google.com') } catch { }
$sw.Stop(); Torol
if ($cimek) { Sor 'OK' 'Névfeloldás (DNS)' ("google.com = $(@($cimek | Where-Object AddressFamily -eq 'InterNetwork')[0]) – $($sw.ElapsedMilliseconds) ms"); $e.dns = $true }
else { Sor 'HIBA' 'Névfeloldás (DNS)' 'a google.com nem oldható fel'; $e.dns = $false }

# 3. Internet IP-cimmel, nevfeloldas nelkul
Varj 'Ping 8.8.8.8...'
$t = Pingel '8.8.8.8' 4; Torol
if ($t.Count) { Sor 'OK' 'Ping 8.8.8.8' "$($t.Count)/4 válasz – $([int]($t | Measure-Object -Average).Average) ms"; $e.ip = $true }
else { Sor 'FIGYELEM' 'Ping 8.8.8.8' 'nem válaszol'; $e.ip = $false }

# 4. google.com, 10 ping
if ($e.dns) {
    Varj 'Ping google.com (10x)...'
    $t = Pingel 'google.com' 10; Torol
    if ($t.Count) {
        $m = $t | Measure-Object -Minimum -Maximum -Average
        $veszt = [int](100 * (10 - $t.Count) / 10)
        $all = 'OK'; if ($veszt -gt 0) { $all = 'FIGYELEM' }
        Sor $all 'Ping google.com' ("$($t.Count)/10 válasz, $veszt% veszt. – átl $([int]$m.Average) ms ($($m.Minimum)–$($m.Maximum))")
        $e.ping = $true; $e.veszt = $veszt
    } else { Sor 'FIGYELEM' 'Ping google.com' 'nem válaszol'; $e.ping = $false }
}

# 5. Valodi weblekeres - a gep proxybeallitasaval
Varj 'Weboldal (https://www.google.com)...'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
try { [Net.WebRequest]::DefaultWebProxy.Credentials = [Net.CredentialCache]::DefaultNetworkCredentials } catch { }
$sw = [Diagnostics.Stopwatch]::StartNew()
$web = $false
try {
    $v = Invoke-WebRequest -UseBasicParsing -Uri 'https://www.google.com/generate_204' -TimeoutSec 10 -Headers @{ 'User-Agent' = 'Eszkozcsere-segedlet' }
    $web = $v.StatusCode -in 200, 204
} catch { }
$sw.Stop(); Torol
if ($web) { Sor 'OK' 'Weboldal' "https://www.google.com – $($sw.ElapsedMilliseconds) ms"; $e.web = $true }
else { Sor 'HIBA' 'Weboldal' 'a https://www.google.com nem érhető el'; $e.web = $false }

# ---------- Osszegzes egy mondatban ----------
if ($e.web -and $e.ping -and $e.veszt -eq 0) { $all = 'OK'; $mondat = 'Az internet rendben van.' }
elseif ($e.web -and $e.ping) { $all = 'FIGYELEM'; $mondat = "Az internet működik, de $($e.veszt)% csomagvesztés van – instabil kapcsolat." }
elseif ($e.web) { $all = 'OK'; $mondat = 'Az internet működik – a ping itt tiltva van, ez céges hálózaton normális.' }
elseif ($e.nincsatjaro) { $all = 'HIBA'; $mondat = 'Nincs hálózati kapcsolat – kábel, Wi-Fi vagy hálózati kártya?' }
elseif (-not $e.dns -and ($e.ip -or $e.router)) { $all = 'HIBA'; $mondat = 'Névfeloldási (DNS) hiba – próbáld: Hálózat helyreállítása, 2 (flushdns).' }
elseif ($e.ip -or $e.ping) { $all = 'HIBA'; $mondat = 'A ping megy, a weboldal nem – céges proxy vagy tűzfal?' }
else { $all = 'HIBA'; $mondat = 'Nincs internet – a helyi hálózat megvan, kifelé nem jut ki.' }
[Console]::WriteLine('')
$szin = switch ($all) { 'OK' { $zold } 'HIBA' { $piros } default { $sarga } }
[Console]::WriteLine('  ' + $szin + $mondat + $nulla)
$naplo.Add('  Eredmény: ' + $mondat)
$naplo.Add('')
try { [IO.File]::AppendAllLines($env:HT_NAPLO, [string[]]$naplo, (New-Object Text.UTF8Encoding $false)) } catch { }
