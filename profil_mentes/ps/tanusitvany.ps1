# ==========================================================
#  Tanusitvanyok (certmgr.msc - Aktualis felhasznalo) mentese es visszaallitasa
#  lib\tipusok\TANUSITVANY.cmd futtatja.
#  Kulcsos tanusitvany: jelszoval vedett .pfx (AES-256), a tobbi: .cer.
#  A fajlnev a tanusitvany ujjlenyomata, a taroloban a mappa neve a tarolo neve.
#  Bemenet:  TAN_MOD     MENT | PROBA | VISSZA
#            TAN_TAROLOK tarolonevek szokozzel, pl. My AddressBook
#            TAN_MAPPA   a mentes Tanusitvanyok mappaja (probanal egy ideiglenes mappa)
#            TAN_KI      eredmenyfajl: 1. allapot, 2. uzenet, 3. reszlet (- ha nincs),
#                        4. a nem mentheto kulcsok szama
#            PM_TESZT_JELSZO  csak a tesztkornyezet adja: ilyenkor nem kerdez
#  A jelszo sehova nem kerul ki: se naploba, se fajlba.
# ==========================================================
$ErrorActionPreference = 'Continue'
$behuz = '           '
$szurke = $env:C_SZURKE; $piros = $env:C_PIROS; $nulla = $env:C_0

function Ki($allapot, $uzenet, $reszlet, $nemexp) {
    if (-not $reszlet) { $reszlet = '-' }
    [IO.File]::WriteAllLines($env:TAN_KI, [string[]]@($allapot, $uzenet, $reszlet, [string]$nemexp), (New-Object Text.UTF8Encoding $false))
    exit 0
}
function Sor($szoveg) {
    if ($szoveg.Length -gt 64) { $szoveg = $szoveg.Substring(0, 63) + '…' }
    [Console]::WriteLine($behuz + $szurke + $szoveg + $nulla)
}
function Hiba($szoveg) { [Console]::WriteLine($behuz + $piros + $szoveg + $nulla) }
function Nev($c) {
    $n = $c.GetNameInfo([Security.Cryptography.X509Certificates.X509NameType]::SimpleName, $false)
    if (-not $n) { $n = $c.Subject }
    $n
}
function Sima($s) {
    $b = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
    try { [Runtime.InteropServices.Marshal]::PtrToStringBSTR($b) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b) }
}
function Jelszo($kerdes) {
    # Csillagokkal kiirt jelszo - a konzolrol olvas, nem a bemenetrol
    if ($env:PM_TESZT_JELSZO) {
        [Console]::WriteLine($behuz + '› ' + $kerdes + ' ********')
        return (ConvertTo-SecureString $env:PM_TESZT_JELSZO -AsPlainText -Force)
    }
    [Console]::Write($behuz + '› ' + $kerdes + ' ')
    $s = New-Object Security.SecureString
    while ($true) {
        $k = [Console]::ReadKey($true)
        if ($k.Key -eq 'Enter') { break }
        if ($k.Key -eq 'Backspace') { if ($s.Length -gt 0) { $s.RemoveAt($s.Length - 1); [Console]::Write("`b `b") }; continue }
        if ($k.KeyChar -ne [char]0) { $s.AppendChar($k.KeyChar); [Console]::Write('*') }
    }
    [Console]::WriteLine()
    $s
}
function PfxKi($c, $f, $p) {
    try { Export-PfxCertificate -Cert $c -FilePath $f -Password $p -CryptoAlgorithmOption AES256_SHA256 -ErrorAction Stop | Out-Null }
    catch [Management.Automation.ParameterBindingException] { Export-PfxCertificate -Cert $c -FilePath $f -Password $p -ErrorAction Stop | Out-Null }
}

$tarolok = @($env:TAN_TAROLOK -split '\s+' | Where-Object { $_ })
$mod = $env:TAN_MOD

# ---------- Visszaallitas ----------
if ($mod -eq 'VISSZA') {
    $pfxek = @(Get-ChildItem -LiteralPath $env:TAN_MAPPA -Recurse -Filter *.pfx -File -ErrorAction SilentlyContinue)
    $cerek = @(Get-ChildItem -LiteralPath $env:TAN_MAPPA -Recurse -Filter *.cer -File -ErrorAction SilentlyContinue)
    if (($pfxek.Count + $cerek.Count) -eq 0) { Ki 'KIHAGYVA' 'a mentésben nincs tanúsítvány' '' 0 }
    $jelszo = $null
    if ($pfxek.Count) {
        Sor 'A kulcsos tanúsítványokhoz a mentéskor megadott jelszó kell.'
        for ($i = 0; $i -lt 3 -and -not $jelszo; $i++) {
            $p = Jelszo 'A tanúsítványok jelszava:'
            if ($p.Length -eq 0) { break }
            try { Get-PfxData -FilePath $pfxek[0].FullName -Password $p -ErrorAction Stop | Out-Null; $jelszo = $p }
            catch { Hiba 'Hibás jelszó.' }
        }
    }
    $vissza = 0; $megvolt = 0; $hiba = 0; $kimaradt = 0
    foreach ($f in @($pfxek + $cerek)) {
        $tarolo = $f.Directory.Name
        $ujj = $f.BaseName
        $hely = "Cert:\CurrentUser\$tarolo"
        # A tarolo letrehozasa, ha meg nincs - a Windows sajat taroloi mindig leteznek
        $st = New-Object Security.Cryptography.X509Certificates.X509Store($tarolo, 'CurrentUser'); $st.Open('ReadWrite'); $st.Close()
        if (Test-Path "$hely\$ujj") { $megvolt++; continue }
        try {
            if ($f.Extension -eq '.pfx') {
                if (-not $jelszo) { $kimaradt++; continue }
                $c = Import-PfxCertificate -FilePath $f.FullName -CertStoreLocation $hely -Password $jelszo -Exportable -ErrorAction Stop
            } else {
                $c = Import-Certificate -FilePath $f.FullName -CertStoreLocation $hely -ErrorAction Stop
            }
            $vissza++
            Sor ($tarolo + ': ' + (Nev $c))
        } catch { $hiba++; Hiba ($tarolo + ': ' + $f.Name + ' – nem importálható') }
    }
    $r = @()
    if ($megvolt) { $r += "$megvolt már megvolt" }
    if ($kimaradt) { $r += "$kimaradt kulcsos kimaradt – nincs jó jelszó" }
    if ($hiba) { $r += "$hiba nem importálható" }
    $allapot = 'OK'; if ($hiba -or $kimaradt) { $allapot = 'HIBA' }
    Ki $allapot "$vissza tanúsítvány visszaállítva" ($r -join ', ') 0
}

# ---------- Mentes es proba ----------
$lista = @()
foreach ($t in $tarolok) {
    foreach ($c in @(Get-ChildItem "Cert:\CurrentUser\$t" -ErrorAction SilentlyContinue)) { $lista += @{ t = $t; c = $c } }
}
if ($lista.Count -eq 0) { Ki 'KIHAGYVA' 'nincs tanúsítvány' '' 0 }

$jelszo = $null
$kulcsos = @($lista | Where-Object { $_.c.HasPrivateKey }).Count
if ($kulcsos -and $mod -eq 'PROBA') {
    # Proba: veletlen jelszoval ideiglenes mappaba - csak azt nezzuk, menthetok-e
    $jelszo = ConvertTo-SecureString ([guid]::NewGuid().ToString()) -AsPlainText -Force
}
elseif ($kulcsos) {
    Sor 'Kulcsos tanúsítványok: jelszóval védem, visszaállításkor kell.'
    for ($i = 0; $i -lt 3 -and -not $jelszo; $i++) {
        $p1 = Jelszo 'Jelszó a tanúsítványokhoz:'
        if ($p1.Length -eq 0) { break }
        $p2 = Jelszo 'Jelszó újra:'
        if ((Sima $p1) -ceq (Sima $p2)) { $jelszo = $p1 } else { Hiba 'A két jelszó nem egyezik.' }
    }
    if (-not $jelszo) { Hiba 'Jelszó nélkül a kulcsos tanúsítványokat nem mentem.' }
}

$pfx = 0; $cer = 0; $nemexp = 0; $nincsjelszo = 0; $hiba = 0
$jegyzek = New-Object Collections.Generic.List[string]
foreach ($e in $lista) {
    $c = $e.c
    $mappa = Join-Path $env:TAN_MAPPA $e.t
    New-Item -ItemType Directory -Force -Path $mappa | Out-Null
    $lejar = $c.NotAfter.ToString('yyyy. MM. dd.')
    $tipus = ''
    if ($c.HasPrivateKey) {
        if (-not $jelszo) { $nincsjelszo++; $tipus = 'kulcsos, NINCS mentve' }
        else {
            $f = Join-Path $mappa ($c.Thumbprint + '.pfx')
            try { PfxKi $c $f $jelszo; $pfx++; $tipus = 'kulccsal' }
            catch { Remove-Item -LiteralPath $f -Force -ErrorAction SilentlyContinue; $nemexp++; $tipus = 'kulcs nem menthető' }
        }
    } else {
        try { Export-Certificate -Cert $c -FilePath (Join-Path $mappa ($c.Thumbprint + '.cer')) -Type CERT -ErrorAction Stop | Out-Null; $cer++; $tipus = 'nyilvános' }
        catch { $hiba++; $tipus = 'HIBA' }
    }
    $eleje = $e.t + ': ' + (Nev $c)
    $max = 60 - $tipus.Length
    if ($eleje.Length -gt $max) { $eleje = $eleje.Substring(0, $max - 1) + '…' }
    Sor ($eleje + ' – ' + $tipus)
    $jegyzek.Add($e.t + ' · ' + (Nev $c) + ' · ' + $lejar + ' · ' + $tipus)
}
if ($mod -ne 'PROBA') {
    $jegyzek.Add('')
    $jegyzek.Add('Eszközcsere segédlet ' + $env:VERZIO + ' · Készítette: ' + $env:SZERZO)
    [IO.File]::WriteAllLines((Join-Path $env:TAN_MAPPA 'lista.txt'), $jegyzek, (New-Object Text.UTF8Encoding $false))
}

$r = @()
if ($pfx) { $r += "$pfx kulccsal" }
if ($cer) { $r += "$cer nyilvános" }
if ($nemexp) { $r += "$nemexp nem menthető kulcs – IT adja ki újra" }
if ($nincsjelszo) { $r += "$nincsjelszo kulcsos nincs mentve, nem volt jelszó" }
if ($hiba) { $r += "$hiba nem menthető" }
$allapot = 'OK'; if ($hiba -or $nincsjelszo) { $allapot = 'HIBA' }
$db = $pfx + $cer
if ($mod -eq 'PROBA') { Ki $allapot "$db tanúsítvány – menthető" ($r -join ', ') $nemexp }
Ki $allapot "$db tanúsítvány mentve" ($r -join ', ') $nemexp
