# ==========================================================
#  Bongeszo profillista mentese - lib\tipusok\BONGESZO.cmd futtatja
#  A Local State-bol csak a profillista kerul ki, a gephez kotott
#  titkositokulcs nem.
#  Bemenet:  LS_SRC - a bongeszo Local State fajlja
#            LS_DST - a kimeneti json
#  Kilepesi kod 2, ha nincs profillista, 1 egyeb hibanal.
# ==========================================================
$ErrorActionPreference = 'Stop'
$j = Get-Content -Raw -Encoding UTF8 -LiteralPath $env:LS_SRC | ConvertFrom-Json
$c = $j.profile.info_cache
if (-not $c) { exit 2 }
ConvertTo-Json -InputObject $c -Depth 50 -Compress | Set-Content -LiteralPath $env:LS_DST -Encoding UTF8
