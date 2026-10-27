# ==========================================================
#  Hamis felhasznaloi profil a tesztekhez - futtat.ps1 hivja
#  -Cel: a profil mappaja. Ekezetes nevek szandekosan: a mentes
#  es a visszaallitas ezeket valtozatlanul kell, hogy atvigye.
# ==========================================================
param([Parameter(Mandatory)][string]$Cel)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding $false

function Mappa($ut) { New-Item -ItemType Directory -Force -Path $ut | Out-Null; $ut }
function Fajl($ut, $szoveg) { Mappa (Split-Path $ut) | Out-Null; [IO.File]::WriteAllText($ut, $szoveg, $utf8) }

$roaming = "$Cel\AppData\Roaming"
$local = "$Cel\AppData\Local"

Fajl "$roaming\Microsoft\Signatures\Aláírás – Dániel.htm" '<html><body>Üdvözlettel, Kakuk Dániel</body></html>'
Fajl "$roaming\Microsoft\Signatures\Aláírás – Dániel_files\colorschememapping.xml" '<xml/>'
Fajl "$roaming\Microsoft\Templates\Sablon.dotx" 'sablon'
Fajl "$Cel\Favorites\Céges portál.url" "[InternetShortcut]`r`nURL=https://intranet.example/"
Fajl "$Cel\Saját adatok – Dániel\jegyzet.txt" 'saját jegyzet'

# PST: 1 MB veletlen tartalom
Mappa "$Cel\PST" | Out-Null
$rnd = New-Object byte[] (1MB); (New-Object Random 42).NextBytes($rnd)
[IO.File]::WriteAllBytes("$Cel\PST\archívum 2024.pst", $rnd)

# Chrome: ket profil es a Local State a profillistaval es egy "titkositokulccsal"
$ud = "$local\Google\Chrome\User Data"
Fajl "$ud\Default\Preferences" '{"profile":{"name":"Dániel"}}'
Fajl "$ud\Default\Bookmarks" '{"roots":{"bookmark_bar":{"children":[{"name":"Céges portál","url":"https://intranet.example/"}]}}}'
Fajl "$ud\Profile 1\Preferences" '{"profile":{"name":"Munka – ő ű"}}'
Fajl "$ud\Local State" '{"os_crypt":{"encrypted_key":"x"},"profile":{"info_cache":{"Default":{"name":"Dániel"},"Profile 1":{"name":"Munka – ő ű"}}}}'

# Start menu rogzitesek
$sm = Mappa "$local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
[IO.File]::WriteAllBytes("$sm\start2.bin", [byte[]](1..64))

"Hamis profil kesz: $Cel"
