# ==========================================================
#  A képernyőgaléria futtatása és ellenőrzése.
#  Kimenet: kimenet\kepernyok.txt. Kilépési kód = a problémák száma.
#  Ellenőrzi: ellenoriz.ps1 -Kredit, a keretek és vonalak pontosan 72 oszlop,
#  az összegzés sorai legfeljebb 76 oszlop.
# ==========================================================
$ErrorActionPreference = 'Stop'
$d = $PSScriptRoot
New-Item -ItemType Directory -Force -Path "$d\kimenet" | Out-Null
$ki = "$d\kimenet\kepernyok.txt"
$env:VALASZ_SORBOL = '1'
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
cmd /c "`"$d\kepernyok.cmd`" < `"$d\valaszok\kepernyok.txt`" > `"$ki`" 2>&1"
$gond = New-Object System.Collections.Generic.List[string]
$e = & "$d\ellenoriz.ps1" -Atirat $ki -Kredit
if ($LASTEXITCODE -gt 0) { $e | Select-Object -SkipLast 1 | ForEach-Object { $gond.Add($_) } }
$tiszta = [regex]::Replace([IO.File]::ReadAllText($ki, [Text.Encoding]::UTF8), [string][char]27 + '\[[0-9;]*m', '')
$sorok = $tiszta -split "`r?`n"
for ($i = 0; $i -lt $sorok.Count; $i++) {
    $s = $sorok[$i]
    if ($s -match '^\s*[═─╔╚║]' -and $s.Length -ne 72) { $gond.Add(('{0}. sor: keret {1} oszlop, nem 72: {2}' -f ($i + 1), $s.Length, $s)) }
    if ($s -match '^    \[' -and $s.Length -gt 76) { $gond.Add(('{0}. sor: összegzés sor {1} oszlop: {2}' -f ($i + 1), $s.Length, $s)) }
}
if (-not $tiszta.Contains('Galéria vége.')) { $gond.Add('A galéria nem futott végig.') }
$gond | ForEach-Object { $_ }
"Problémák: $($gond.Count)"
exit $gond.Count
