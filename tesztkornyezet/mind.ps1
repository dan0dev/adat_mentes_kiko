# ==========================================================
#  Minden forgatokonyv futtatasa es osszevetese az alap\ eredmenyekkel.
#  Kilepesi kod = a hibas forgatokonyvek szama.
#  -AtiratKodlap  az atirat kodlapja (regi verzio: 852, uj: 65001)
#  -Ellenoriz     az ellenoriz.ps1 is fusson (csipogas, hossz, cmd hiba, mojibake)
#  -Kredit        a "Készítette" sor is kotelezo
#  -Szoveg        ekezet nelkuli es magazo szavak keresese is
#  -Csak          csak ezek a forgatokonyvek
# ==========================================================
param(
    [int]$AtiratKodlap = 65001,
    [switch]$Ellenoriz,
    [switch]$Kredit,
    [switch]$Szoveg,
    [string[]]$Csak
)
$ErrorActionPreference = 'Stop'
$d = $PSScriptRoot
$m = "$env:TEMP\pm_teszt\kulso\Mentes\$($env:USERNAME)_$($env:COMPUTERNAME)"
$sorrend = 'mentes', 'probafuttatas', 'visszaallitas', 'laptop_megse', 'alapalk_ellenoriz', 'hibas_bevitel', 'visszaallitas_hibas', 'regi_mentes'
if ($Csak) { $sorrend = $sorrend | Where-Object { $Csak -contains $_ } }
$hibak = 0
foreach ($v in $sorrend) {
    $gond = New-Object System.Collections.Generic.List[string]
    $arg = @{ Valaszok = $v; AtiratKodlap = $AtiratKodlap }
    if ($v -eq 'mentes') { $arg.Tiszta = $true }
    $mappa = $m
    if ($v -eq 'regi_mentes') {
        # A regi verzio altal keszitett mentes visszaallitasa: a _LEFT-TO-DO.txt-t folytatja,
        # nem nyit ujat, es a regi _EXPORT_ osszegzest lecsereli
        $arg.Mentes = "$d\alap\mentes_regi"
        $mappa = "$env:TEMP\pm_teszt\kulso\Mentes\mentes_regi"
    }
    # Tanusitvanyok: mentes elott a harom teszt tanusitvany (kulcsos, nem exportalhato, nyilvanos),
    # visszaallitas elott ures tarolo - utana a kulcsos es a nyilvanos ujra ott kell legyen
    if ($v -eq 'mentes') { & "$d\profil_feltolt.ps1" -CsakTanusitvany }
    if ($v -eq 'visszaallitas') { & "$d\profil_feltolt.ps1" -TanusitvanyUrit }
    $atirat = & "$d\futtat.ps1" @arg
    if ($v -eq 'mentes') {
        $ch = "$mappa\Chrome_mentes\Default"
        foreach ($f in 'Bookmarks', 'History', 'History Provider Cache', 'Preferences') {
            if (-not (Test-Path -LiteralPath "$ch\$f")) { $gond.Add("Chrome: hianyzik a mentesbol: Default\$f") }
        }
        $tan = @(Get-ChildItem "$mappa\Tanusitvanyok\PmTeszt" -File -ErrorAction SilentlyContinue)
        if (@($tan | Where-Object Extension -eq '.pfx').Count -ne 1) { $gond.Add('tanusitvany: nem 1 .pfx') }
        if (@($tan | Where-Object Extension -eq '.cer').Count -ne 1) { $gond.Add('tanusitvany: nem 1 .cer') }
        if (-not (Test-Path "$mappa\Tanusitvanyok\lista.txt")) { $gond.Add('tanusitvany: nincs lista.txt') }
        $todo = [IO.File]::ReadAllText("$mappa\_TEENDOK.txt", [Text.Encoding]::UTF8)
        if (-not $todo.Contains('1 kulcs nem menthető')) { $gond.Add('_TEENDOK.txt: hianyzik a nem mentheto kulcs sora') }
    }
    if ($v -eq 'visszaallitas') {
        $vissza = @(Get-ChildItem Cert:\CurrentUser\PmTeszt)
        if ($vissza.Count -ne 2) { $gond.Add("tanusitvany: visszaallitas utan $($vissza.Count) db, nem 2") }
        if (@($vissza | Where-Object HasPrivateKey).Count -ne 1) { $gond.Add('tanusitvany: a kulcsos nem kulccsal allt vissza') }
    }
    if ($v -eq 'regi_mentes') {
        $todo = "$mappa\_LEFT-TO-DO.txt"
        if (-not (Test-Path $todo)) { $gond.Add('nincs _LEFT-TO-DO.txt') }
        elseif (-not ([IO.File]::ReadAllText($todo, [Text.Encoding]::UTF8)).Contains('VISSZAÁLLÍTÁS – ')) { $gond.Add('a _LEFT-TO-DO.txt nem kapta meg a visszaállítás részt') }
        if (Test-Path "$mappa\_TEENDOK.txt") { $gond.Add('uj _TEENDOK.txt keszult a regi _LEFT-TO-DO.txt melle') }
        $vo = @(Get-ChildItem $mappa -Filter '_VISSZAALLITAS_*.txt'); $ex = @(Get-ChildItem $mappa -Filter '_EXPORT_*.txt')
        if ($vo.Count -ne 1) { $gond.Add("_VISSZAALLITAS_*.txt: $($vo.Count) db, nem 1") }
        if ($ex.Count -ne 0) { $gond.Add("regi _EXPORT_*.txt maradt: $($ex.Count) db") }
    }
    $alapFajl = "$d\alap\$v.json"
    if (Test-Path $alapFajl) {
        $alap = Get-Content $alapFajl -Raw -Encoding UTF8 | ConvertFrom-Json
        $uj = (& "$d\eredmeny.ps1" -Atirat $atirat -Mentes $mappa) | ConvertFrom-Json
        foreach ($k in 'sikeres', 'hibas', 'kihagyva') {
            if ($alap.$k -ne $uj.$k) { $gond.Add("$k : alap $($alap.$k), most $($uj.$k)") }
        }
        $hianyzik = @($alap.fajlok | Where-Object { $uj.fajlok -notcontains $_ })
        $tobblet = @($uj.fajlok | Where-Object { $alap.fajlok -notcontains $_ })
        if ($hianyzik) { $gond.Add('hianyzo fajl: ' + ($hianyzik -join ', ')) }
        if ($tobblet) { $gond.Add('tobblet fajl: ' + ($tobblet -join ', ')) }
    } else { $gond.Add("nincs alap: $alapFajl") }
    if ($Ellenoriz) {
        $e = @{ Atirat = $atirat }
        if ($Kredit) { $e.Kredit = $true }
        if ($Szoveg) { $e.Szoveg = $true }
        $ki = & "$d\ellenoriz.ps1" @e
        if ($LASTEXITCODE -gt 0) { $ki | Select-Object -SkipLast 1 | ForEach-Object { $gond.Add($_) } }
    }
    if ($gond.Count) { $hibak++; "FAIL  $v"; $gond | ForEach-Object { "      $_" } } else { "ok    $v" }
}
# A teszt tanusitvanyok es kulcsaik ne maradjanak a gepen
& "$d\profil_feltolt.ps1" -TanusitvanyUrit
"Hibas forgatokonyvek: $hibak / $($sorrend.Count)"
exit $hibak
