# ==========================================================
#  Tanusitvanyok (certmgr.msc - Aktualis felhasznalo) mentese es visszaallitasa
#  lib\tipusok\TANUSITVANY.cmd futtatja.
#  Csak a kulcs nelkuli tanusitvanyok kerulnek at, .cer fajlban.
#  A fajlnev a tanusitvany ujjlenyomata, a taroloban a mappa neve a tarolo neve.
#  Bemenet:  TAN_MOD     MENT | PROBA | VISSZA
#            TAN_TAROLOK tarolonevek szokozzel, pl. My AddressBook
#            TAN_MAPPA   a mentes Tanusitvanyok mappaja (probanal egy ideiglenes mappa)
#            TAN_KI      eredmenyfajl: 1. allapot, 2. uzenet, 3. reszlet (- ha nincs)
# ==========================================================
$ErrorActionPreference = 'Continue'
$behuz = '           '
$szurke = $env:C_SZURKE; $piros = $env:C_PIROS; $nulla = $env:C_0

function Ki($allapot, $uzenet, $reszlet) {
    if (-not $reszlet) { $reszlet = '-' }
    [IO.File]::WriteAllLines($env:TAN_KI, [string[]]@($allapot, $uzenet, $reszlet), (New-Object Text.UTF8Encoding $false))
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

$tarolok = @($env:TAN_TAROLOK -split '\s+' | Where-Object { $_ })
$mod = $env:TAN_MOD

# ---------- Visszaallitas ----------
if ($mod -eq 'VISSZA') {
    $cerek = @(Get-ChildItem -LiteralPath $env:TAN_MAPPA -Recurse -Filter *.cer -File -ErrorAction SilentlyContinue)
    if ($cerek.Count -eq 0) { Ki 'KIHAGYVA' 'a mentésben nincs tanúsítvány' '' }
    $vissza = 0; $megvolt = 0; $hiba = 0
    foreach ($f in $cerek) {
        $tarolo = $f.Directory.Name
        $ujj = $f.BaseName
        $hely = "Cert:\CurrentUser\$tarolo"
        # A tarolo letrehozasa, ha meg nincs - a Windows sajat taroloi mindig leteznek
        $st = New-Object Security.Cryptography.X509Certificates.X509Store($tarolo, 'CurrentUser'); $st.Open('ReadWrite'); $st.Close()
        if (Test-Path "$hely\$ujj") { $megvolt++; continue }
        try {
            $c = Import-Certificate -FilePath $f.FullName -CertStoreLocation $hely -ErrorAction Stop
            $vissza++
            Sor ($tarolo + ': ' + (Nev $c))
        } catch { $hiba++; Hiba ($tarolo + ': ' + $f.Name + ' – nem importálható') }
    }
    $r = @()
    if ($megvolt) { $r += "$megvolt már megvolt" }
    if ($hiba) { $r += "$hiba nem importálható" }
    $allapot = 'OK'; if ($hiba) { $allapot = 'HIBA' }
    Ki $allapot "$vissza tanúsítvány visszaállítva" ($r -join ', ')
}

# ---------- Mentes es proba ----------
$lista = @()
foreach ($t in $tarolok) {
    foreach ($c in @(Get-ChildItem "Cert:\CurrentUser\$t" -ErrorAction SilentlyContinue | Where-Object { -not $_.HasPrivateKey })) { $lista += @{ t = $t; c = $c } }
}
if ($lista.Count -eq 0) { Ki 'KIHAGYVA' 'nincs tanúsítvány' '' }

$cer = 0; $hiba = 0
$jegyzek = New-Object Collections.Generic.List[string]
foreach ($e in $lista) {
    $c = $e.c
    $mappa = Join-Path $env:TAN_MAPPA $e.t
    New-Item -ItemType Directory -Force -Path $mappa | Out-Null
    $lejar = $c.NotAfter.ToString('yyyy. MM. dd.')
    $eleje = $e.t + ': ' + (Nev $c)
    try {
        Export-Certificate -Cert $c -FilePath (Join-Path $mappa ($c.Thumbprint + '.cer')) -Type CERT -ErrorAction Stop | Out-Null
        $cer++
        Sor $eleje
        $jegyzek.Add($e.t + ' · ' + (Nev $c) + ' · ' + $lejar)
    } catch {
        $hiba++
        Hiba ($eleje + ' – nem menthető')
        $jegyzek.Add($e.t + ' · ' + (Nev $c) + ' · ' + $lejar + ' · HIBA')
    }
}
if ($mod -ne 'PROBA') {
    $jegyzek.Add('')
    $jegyzek.Add('Eszközcsere segédlet ' + $env:VERZIO + ' · Készítette: ' + $env:SZERZO)
    [IO.File]::WriteAllLines((Join-Path $env:TAN_MAPPA 'lista.txt'), $jegyzek, (New-Object Text.UTF8Encoding $false))
}

$r = ''
if ($hiba) { $r = "$hiba nem menthető" }
$allapot = 'OK'; if ($hiba) { $allapot = 'HIBA' }
if ($mod -eq 'PROBA') { Ki $allapot "$cer tanúsítvány – menthető" $r }
Ki $allapot "$cer tanúsítvány mentve" $r
