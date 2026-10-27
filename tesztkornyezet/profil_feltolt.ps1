# ==========================================================
#  Hamis felhasznaloi profil a tesztekhez - futtat.ps1 hivja
#  -Cel: a profil mappaja. Ekezetes nevek szandekosan: a mentes
#  es a visszaallitas ezeket valtozatlanul kell, hogy atvigye.
# ==========================================================
param(
    [string]$Cel,
    [switch]$CsakTanusitvany,
    [switch]$TanusitvanyUrit
)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding $false

# ---------- Teszt tanusitvanyok: kulon PmTeszt tarolo a valodi felhasznaloban ----------
# A valodi Szemelyes taroloban csak egy pillanatra jelennek meg (a New-SelfSignedCertificate
# csak oda tud irni), utana atkerulnek a PmTeszt taroloba.
function TanusitvanyUrit {
    if (Test-Path Cert:\CurrentUser\PmTeszt) {
        Get-ChildItem Cert:\CurrentUser\PmTeszt | ForEach-Object { Remove-Item -Path "Cert:\CurrentUser\PmTeszt\$($_.Thumbprint)" -DeleteKey }
    }
}
function TanusitvanyAlap {
    TanusitvanyUrit
    $st = New-Object Security.Cryptography.X509Certificates.X509Store('PmTeszt', 'CurrentUser'); $st.Open('ReadWrite')
    $exp = New-SelfSignedCertificate -Subject 'CN=Eszközcsere teszt – kulcsos' -CertStoreLocation Cert:\CurrentUser\My -KeyExportPolicy Exportable -NotAfter (Get-Date).AddYears(1)
    $nem = New-SelfSignedCertificate -Subject 'CN=Eszközcsere teszt – nem exportálható' -CertStoreLocation Cert:\CurrentUser\My -KeyExportPolicy NonExportable -NotAfter (Get-Date).AddYears(1)
    $nyi = New-SelfSignedCertificate -Subject 'CN=Eszközcsere teszt – nyilvános' -CertStoreLocation Cert:\CurrentUser\My -NotAfter (Get-Date).AddYears(1)
    $st.Add($exp); $st.Add($nem)
    # Nyilvanos: csak a tanusitvany, kulcs nelkul
    $st.Add((New-Object Security.Cryptography.X509Certificates.X509Certificate2 (, $nyi.RawData)))
    $st.Close()
    Remove-Item "Cert:\CurrentUser\My\$($exp.Thumbprint)"
    Remove-Item "Cert:\CurrentUser\My\$($nem.Thumbprint)"
    Remove-Item "Cert:\CurrentUser\My\$($nyi.Thumbprint)" -DeleteKey
}
if ($TanusitvanyUrit) { TanusitvanyUrit; return }
if ($CsakTanusitvany) { TanusitvanyAlap; return }
if (-not $Cel) { throw 'A -Cel kotelezo.' }

function Mappa($ut) { New-Item -ItemType Directory -Force -Path $ut | Out-Null; $ut }
function Fajl($ut, $szoveg) { Mappa (Split-Path $ut) | Out-Null; [IO.File]::WriteAllText($ut, $szoveg, $utf8) }

$roaming = "$Cel\AppData\Roaming"
$local = "$Cel\AppData\Local"

Fajl "$roaming\Microsoft\Signatures\Aláírás – Dániel.htm" '<html><body>Üdvözlettel, Kakuk Dániel</body></html>'
Fajl "$roaming\Microsoft\Signatures\Aláírás – Dániel_files\colorschememapping.xml" '<xml/>'
Fajl "$roaming\Microsoft\Templates\Sablon.dotx" 'sablon'
Fajl "$Cel\Favorites\Céges portál.url" "[InternetShortcut]`r`nURL=https://intranet.example/"
Fajl "$Cel\Saját adatok – Dániel\jegyzet.txt" 'saját jegyzet'
# A C:\TEMP helyett - a teszt_konfig.cmd ide iranyitja
Fajl "$Cel\_C_TEMP\teszt.txt" 'teszt C:\TEMP tartalom'

# PST: 1 MB veletlen tartalom
Mappa "$Cel\PST" | Out-Null
$rnd = New-Object byte[] (1MB); (New-Object Random 42).NextBytes($rnd)
[IO.File]::WriteAllBytes("$Cel\PST\archívum 2024.pst", $rnd)

# Chrome: ket profil es a Local State a profillistaval es egy "titkositokulccsal"
$ud = "$local\Google\Chrome\User Data"
Fajl "$ud\Default\Preferences" '{"profile":{"name":"Dániel"}}'
Fajl "$ud\Default\Bookmarks" '{"roots":{"bookmark_bar":{"children":[{"name":"Céges portál","url":"https://intranet.example/"}]}}}'
# A Chrome mind a negy mentendo fajlja: Bookmarks, History, History Provider Cache, Preferences
Fajl "$ud\Default\History" 'SQLite format 3 – teszt előzmények'
Fajl "$ud\Default\History Provider Cache" 'teszt előzmény-gyorsítótár'
Fajl "$ud\Profile 1\Preferences" '{"profile":{"name":"Munka – ő ű"}}'
Fajl "$ud\Local State" '{"os_crypt":{"encrypted_key":"x"},"profile":{"info_cache":{"Default":{"name":"Dániel"},"Profile 1":{"name":"Munka – ő ű"}}}}'

# Start menu rogzitesek
$sm = Mappa "$local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
[IO.File]::WriteAllBytes("$sm\start2.bin", [byte[]](1..64))

"Hamis profil kesz: $Cel"
