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
$sorrend = 'mentes', 'probafuttatas', 'visszaallitas', 'laptop_megse', 'alapalk_ellenoriz', 'hibas_bevitel', 'visszaallitas_hibas'
if ($Csak) { $sorrend = $sorrend | Where-Object { $Csak -contains $_ } }
$hibak = 0
foreach ($v in $sorrend) {
    $gond = New-Object System.Collections.Generic.List[string]
    $arg = @{ Valaszok = $v; AtiratKodlap = $AtiratKodlap }
    if ($v -eq 'mentes') { $arg.Tiszta = $true }
    $atirat = & "$d\futtat.ps1" @arg
    $alapFajl = "$d\alap\$v.json"
    if (Test-Path $alapFajl) {
        $alap = Get-Content $alapFajl -Raw -Encoding UTF8 | ConvertFrom-Json
        $uj = (& "$d\eredmeny.ps1" -Atirat $atirat -Mentes $m) | ConvertFrom-Json
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
