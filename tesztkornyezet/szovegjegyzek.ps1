# ==========================================================
#  Szövegjegyzék: a segédlet minden felhasználónak szóló szövege egy táblában,
#  hogy a teljes szöveg egy helyen átnézhető legyen.
#  Kimenet: ..\docs\szovegjegyzek.md   (fájl:sor | szöveg)
#  Forrás: echo sorok, %UI% :CIM/:FEJLEC/:JELOL/:RESZLET/:VALASZT/:BEKER/:SAV/:MENU/:ADAT
#  hívások paraméterei, a config\tetelek.cmd tételnevei és a ps\ fájlok szövegei.
# ==========================================================
$ErrorActionPreference = 'Stop'
$gyoker = Split-Path $PSScriptRoot
$tool = Join-Path $gyoker 'profil_mentes'
$ki = Join-Path $gyoker 'docs\szovegjegyzek.md'
$sorok = New-Object System.Collections.Generic.List[string]

function Tisztit($s) {
    $s = [regex]::Replace($s, '!C_[A-Z_0-9]+!', '')
    $s = $s -replace '\^(.)', '$1'
    $s.Trim()
}

foreach ($f in Get-ChildItem $tool -Recurse -Include *.cmd, *.bat -File | Sort-Object FullName) {
    $rel = $f.FullName.Substring($tool.Length + 1)
    $n = 0
    foreach ($l in [IO.File]::ReadAllLines($f.FullName, [Text.Encoding]::UTF8)) {
        $n++
        $t = $l.Trim()
        if ($t -match '^rem\b' -or $t -eq '') { continue }
        # echo sorok - az echo. es az echo ^<xml szeru sorok nelkul
        if ($t -match '^(?:>>?"[^"]+"\s+)?echo\s+(.+)$' -and $t -notmatch '^>>?"[^"]*(XML|APPS|TALCA)') {
            $sz = Tisztit $Matches[1]
            if ($sz -and $sz -notmatch '^\^<|^\.$|^%%' -and $sz.Length -gt 1) { $sorok.Add(('| `{0}:{1}` | {2} |' -f $rel, $n, ($sz -replace '\|', '\|'))) }
            continue
        }
        # UI hivasok: minden idezojeles parameter
        if ($t -match '%UI%\s+:(CIM|FEJLEC|JELOL|RESZLET|VALASZT|BEKER|SAV|MENU|ADAT|SZAKASZ)\b') {
            foreach ($m in [regex]::Matches($t, '"([^"]*)"')) {
                $sz = Tisztit $m.Groups[1].Value
                if ($sz -and $sz -notmatch '^[%!][A-Z_~0-9]+[%!]$' -and $sz -notmatch '^%~\d$') { $sorok.Add(('| `{0}:{1}` | {2} |' -f $rel, $n, ($sz -replace '\|', '\|'))) }
            }
            continue
        }
        # tetelnevek es az egyeb config sorok masodik idezojeles oszlopa
        if ($t -match '^%(TETEL|AA_PROGRAM|AA_ELLENORIZ|IKON_APP)%') {
            $m = [regex]::Match($t, '"([^"]*)"'); if ($m.Success) { $sorok.Add(('| `{0}:{1}` | {2} |' -f $rel, $n, $m.Groups[1].Value)) }
        }
    }
}
foreach ($f in Get-ChildItem (Join-Path $tool 'ps') -Filter *.ps1 | Sort-Object Name) {
    $n = 0
    foreach ($l in [IO.File]::ReadAllLines($f.FullName, [Text.Encoding]::UTF8)) {
        $n++
        if ($l.Trim().StartsWith('#')) { continue }
        foreach ($m in [regex]::Matches($l, "'([^']*[áéíóöőúüűÁÉÍÓÖŐÚÜŰ][^']*)'")) {
            $sorok.Add(('| `ps\{0}:{1}` | {2} |' -f $f.Name, $n, ($m.Groups[1].Value -replace '\|', '\|')))
        }
    }
}

$fej = @(
    '# Szövegjegyzék – Eszközcsere segédlet 1.0',
    '',
    ('Generálta: `tesztkornyezet\szovegjegyzek.ps1` – ' + (Get-Date -Format 'yyyy. MM. dd.') + ' – ' + $sorok.Count + ' szöveg.'),
    'Minden felhasználónak szóló szöveg egy helyen, lektoráláshoz. A javítás a forrásfájlban történik, a jegyzék újragenerálható.',
    '',
    '| Hely | Szöveg |',
    '|---|---|'
)
[IO.File]::WriteAllLines($ki, ($fej + $sorok), (New-Object Text.UTF8Encoding $false))
"Szövegjegyzék: $ki – $($sorok.Count) sor"
