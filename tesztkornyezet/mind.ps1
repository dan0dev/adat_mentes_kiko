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
$sorrend = 'mentes', 'visszaallitas', 'bitlocker_megse', 'chrome_megse', 'eszkozok_megse', 'admin_eszkozok', 'admin_masik_fiok', 'frissites_git', 'hibas_bevitel', 'visszaallitas_hibas', 'regi_mentes'
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
    # Rendszergazdai agak: a segedlet azt hiszi, rendszergazdakent fut (PM_TESZT_ADMIN);
    # admin_masik_fiok: egy masik fiok nevevel - a mentesnek meg kell allnia
    $regiNev = $env:USERNAME
    if ($v -like 'admin_*') { $env:PM_TESZT_ADMIN = '1' }
    if ($v -eq 'admin_masik_fiok') { $env:USERNAME = 'masik_rendszergazda' }
    try { $atirat = & "$d\futtat.ps1" @arg }
    finally { Remove-Item Env:PM_TESZT_ADMIN -ErrorAction SilentlyContinue; $env:USERNAME = $regiNev }
    if ($v -eq 'mentes') {
        $ch = "$mappa\Chrome_mentes\Default"
        foreach ($f in 'Bookmarks', 'History', 'History Provider Cache', 'Preferences') {
            if (-not (Test-Path -LiteralPath "$ch\$f")) { $gond.Add("Chrome: hianyzik a mentesbol: Default\$f") }
        }
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
"Hibas forgatokonyvek: $hibak / $($sorrend.Count)"
exit $hibak
