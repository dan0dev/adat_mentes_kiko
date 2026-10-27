# ==========================================================
#  Atirat ellenorzese. Soronkent egy problema, kilepesi kod = a problemak szama.
#  -Atirat   a futtat.ps1 altal irt UTF-8 atirat
#  -Vege     ennek a szovegnek az utolso 15 sorban kell lennie
#  -Kredit   a "Készítette: Kakuk Dániel" sornak szerepelnie kell
#  -Szoveg   ekezet nelkuli es magazo szavak keresese
# ==========================================================
param(
    [Parameter(Mandatory)][string]$Atirat,
    [string]$Vege,
    [switch]$Kredit,
    [switch]$Szoveg
)
$ErrorActionPreference = 'Stop'
$nyers = [IO.File]::ReadAllText($Atirat, [Text.Encoding]::UTF8)
$problemak = New-Object System.Collections.Generic.List[string]

if ($nyers.Contains([char]7)) { $problemak.Add('BEL (csipogas) karakter az atiratban') }

$tiszta = [regex]::Replace($nyers, [string][char]27 + '\[[0-9;]*m', '')
# A kerdesek elotti pont + visszatorles a kepernyon nem latszik - a hosszba sem szamit
$tiszta = $tiszta.Replace('.' + [char]8, '')
$sorok = $tiszta -split "`r?`n"

for ($i = 0; $i -lt $sorok.Count; $i++) {
    $s = $sorok[$i]
    # A robocopy folyamatjelzo sorai tabulatorral kezdodnek, es a robocopy ezeket mindig a 852-es
    # kodlapon irja - az atiratban ezert nem UTF-8-ak. A segedlet sajat soraiban nincs tabulator.
    if ($s -match 'Ã|Å|Ĺ|Ă|â€|�' -and -not $s.Contains("`t")) { $problemak.Add(('{0}. sor: hibas ekezet (mojibake): {1}' -f ($i + 1), $s.Trim())) }
    if ($s.Length -gt 76 -and $s -notmatch ':\\|\\\\') { $problemak.Add(('{0}. sor: {1} karakter, tul hosszu: {2}' -f ($i + 1), $s.Length, $s.Trim())) }
    if ($s -match 'unexpected at this time|not recognized as an internal|cannot find the batch label|nem várt|kötegcímke|syntax of the command is incorrect') {
        $problemak.Add(('{0}. sor: cmd hiba: {1}' -f ($i + 1), $s.Trim()))
    }
}

if ($Vege) {
    $utolso = ($sorok | Select-Object -Last 15) -join "`n"
    if (-not $utolso.Contains($Vege)) { $problemak.Add("Az utolso 15 sorban nincs: $Vege") }
}
if ($Kredit -and -not $tiszta.Contains('Készítette: Kakuk Dániel')) { $problemak.Add('Hianyzik: Készítette: Kakuk Dániel') }

if ($Szoveg) {
    $ekezetNelkul = 'felhasznalo', 'szamitogep', 'jogosultsag', 'valaszt', 'mentese', 'visszaallit', 'ellenoriz', 'ellenorz',
        'osszegz', 'teendo', 'idotartam', 'kesz', 'meghajto', 'kulso', 'fajl', 'folytatas', 'megszakit', 'tetel', 'eleg',
        'masol', 'bezar', 'inditas', 'beallit', 'alapertelmezett'
    $magazo = 'válasszon', 'adjon', 'nyomjon', 'húzza', 'indítsa', 'másolja', 'ellenőrizze', 'nézze', 'válaszoljon', 'formázza',
        'használjon', 'jelentkezzen', 'törölje', 'állítsa', 'rögzítse', 'kövesse', 'csatolja', 'vesse', 'írja', 'javítsa', 'zárja', 'kapcsolja'
    for ($i = 0; $i -lt $sorok.Count; $i++) {
        $tokenek = $sorok[$i] -split '[\s,;()\[\]?“”]+' | Where-Object { $_ -and $_ -notmatch '[_\\.:]' }
        foreach ($t in $tokenek) {
            $kis = $t.ToLowerInvariant()
            foreach ($e in $ekezetNelkul) { if ($kis.StartsWith($e)) { $problemak.Add(('{0}. sor: ekezet nelkuli szo: {1}' -f ($i + 1), $t)); break } }
            if ($magazo -contains $kis) { $problemak.Add(('{0}. sor: magazo alak: {1}' -f ($i + 1), $t)) }
        }
    }
}

$problemak | ForEach-Object { $_ }
"Problemak: $($problemak.Count)"
exit $problemak.Count
