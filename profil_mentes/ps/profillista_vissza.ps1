# ==========================================================
#  Bongeszo profillista visszaallitasa - lib\tipusok\BONGESZO.cmd futtatja
#  Uj Local State csak a profillistaval - a bongeszo sajat, uj kulcsot general.
#  Bemenet:  LS_JSON - a mentett profillista
#            LS_DST  - a bongeszo Local State fajlja
# ==========================================================
$ErrorActionPreference = 'Stop'
$c = Get-Content -Raw -Encoding UTF8 -LiteralPath $env:LS_JSON | ConvertFrom-Json
$o = @{ profile = @{ info_cache = $c } }
$t = ConvertTo-Json -InputObject $o -Depth 50 -Compress
[IO.File]::WriteAllText($env:LS_DST, $t)
