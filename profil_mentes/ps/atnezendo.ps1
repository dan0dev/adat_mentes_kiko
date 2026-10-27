# ==========================================================
#  Kezzel atnezendo mappak - lib\atnezendo.cmd futtatja
#  Csak olvas, semmit nem masol. Soronkent egy talalat:
#    meret   utvonal   - megjegyzes
#  1. A szabvanyos mappak - Letoltesek, Asztal, Dokumentumok... -: hol vannak,
#     helyben vagy a halozaton, es mekkorak.
#  2. A nem szabvanyos mappak a C: gyokereben es a felhasznalo mappajaban,
#     meret szerint csokkenoen - itt szokott lenni a felhasznalo sajat mappaja.
#  3. A csatolt PST-k mappai, ha mashol vannak.
#  Bemenet: ATNEZ_KIHAGY_C, ATNEZ_KIHAGY_PROFIL - kihagyott nevek, pontosvesszovel, * hasznalhato
#           ATNEZ_IDOKORLAT_MP - ennyi ido utan a tobbi mappa meretet mar nem meri
#           ATNEZ_PSTK - a PST mappan kivuli csatolt PST-k, pontosvesszovel
#           ATN_KI - ide irja a listat, a kepernyore is kiirja
#  A meretet a robocopy listazo modja adja - sokkal gyorsabb, mint a Get-ChildItem.
#  A mappakat egyszerre meri, igy egy nagy mappa nem veszi el az idot a tobbitol.
# ==========================================================
$ErrorActionPreference = 'SilentlyContinue'
$ora = [Diagnostics.Stopwatch]::StartNew()
$korlat = 60; if ($env:ATNEZ_IDOKORLAT_MP -match '^\d+$') { $korlat = [int]$env:ATNEZ_IDOKORLAT_MP }
$egyszerre = 6
# Hashtable, hogy a fuggvenyek is modosithassak - szovegkent betoltve a $script: nem ide mutat
$allapot = @{ lekeses = $false }
$psts = @($env:ATNEZ_PSTK -split ';' | Where-Object { $_ })
$haladas = -not [Console]::IsOutputRedirected
# A haladas sora ne torjon at - akkor a `r nem az elejere allna vissza
$szelesseg = 72; if ($haladas) { $szelesseg = [Math]::Min(72, [Console]::WindowWidth - 1) }

function Halad($szoveg) {
    if ($haladas) { [Console]::Write("`r" + $szoveg.PadRight($szelesseg).Substring(0, $szelesseg) + "`r") }
}
function Olvas($ki) {
    # A robocopy osszesitojebol a bajtok szama, -1 ha nem merheto
    $sorok = @(Get-Content -LiteralPath $ki | Where-Object { $_ -match ':\s+(\d+)\s+\d+' })
    Remove-Item -LiteralPath $ki -Force
    if ($sorok.Count -ge 3) { return [long]([regex]::Match($sorok[2], ':\s+(\d+)').Groups[1].Value) }
    return -1
}
function MerdMind($utak) {
    # Utvonal -> bajt: -1 ha nem merheto, -2 ha lejart az idokorlat - a futo merest is leallitja
    $meret = @{}
    $sor = New-Object System.Collections.Queue
    foreach ($u in $utak) { if (-not $meret.ContainsKey($u)) { $meret[$u] = -2; $sor.Enqueue($u) } }
    $ossz = $sor.Count; $kesz = 0
    $futo = @()
    while ($sor.Count -or $futo.Count) {
        while ($futo.Count -lt $egyszerre -and $sor.Count) {
            $u = $sor.Dequeue()
            $ki = Join-Path $env:TEMP ('_atnezendo_' + [guid]::NewGuid().ToString('N') + '.txt')
            $arg = '"' + $u.TrimEnd('\') + '" "' + $env:TEMP + '\_atnezendo_nincs_ilyen" /L /S /XJ /NJH /NFL /NDL /NC /NS /BYTES /R:0 /W:0 /MT:8'
            $p = Start-Process -FilePath robocopy.exe -ArgumentList $arg -RedirectStandardOutput $ki -NoNewWindow -PassThru
            if ($p) { $futo += @{ ut = $u; p = $p; ki = $ki } } else { $meret[$u] = -1; $kesz++ }
        }
        $marad = @()
        foreach ($f in $futo) {
            if ($f.p.HasExited) { $meret[$f.ut] = Olvas $f.ki; $kesz++ } else { $marad += $f }
        }
        $futo = $marad
        if ($ora.Elapsed.TotalSeconds -ge $korlat) {
            foreach ($f in $futo) {
                try { $f.p.Kill(); $f.p.WaitForExit() } catch { }
                Remove-Item -LiteralPath $f.ki -Force
            }
            if ($futo.Count -or $sor.Count) { $allapot.lekeses = $true }
            break
        }
        Halad ('   Meres: {0}/{1} mappa kesz, {2}/{3} mp' -f $kesz, $ossz, [int]$ora.Elapsed.TotalSeconds, $korlat)
        Start-Sleep -Milliseconds 100
    }
    Halad ''
    return $meret
}
function Szoveg($b) {
    if ($b -lt 0)   { return '?' }
    if ($b -ge 1GB) { return ('{0:0.0} GB' -f ($b / 1GB)).Replace('.', ',') }
    if ($b -ge 1MB) { return ('{0:0} MB' -f ($b / 1MB)) }
    return '< 1 MB'
}
function Sor($b, $ut, $megj) {
    if ($b -eq -1) { $megj += ', merete nem merheto - nincs jog' }
    if ($b -eq -2) { $megj += ', merete nem ismert - idokorlat' }
    '{0,8}   {1}   - {2}' -f (Szoveg $b), $ut, $megj
}
function VanPst($ut) {
    $e = $ut.TrimEnd('\') + '\'
    foreach ($p in $psts) { if ($p.StartsWith($e, [StringComparison]::OrdinalIgnoreCase)) { return $true } }
    return $false
}
function Kihagy($nev, $lista) {
    foreach ($m in $lista) { if ($m -and $nev -like $m) { return $true } }
    return $false
}

# 1. Szabvanyos mappak: nev, registry ertek, alap mappa, mindig kiirja-e
$usf = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
$ismert = @(
    @('Letoltesek',   '{374DE290-123F-4565-9164-39C4925E467B}', 'Downloads', $true),
    @('Asztal',       'Desktop',     'Desktop',   $true),
    @('Dokumentumok', 'Personal',    'Documents', $true),
    @('Kepek',        'My Pictures', 'Pictures',  $false),
    @('Videok',       'My Video',    'Videos',    $false),
    @('Zene',         'My Music',    'Music',     $false)
)
# Elobb osszegyujti a mappakat, a vegen egyszerre meri le oket
$szabvanyos = @()
foreach ($k in $ismert) {
    $ut = $usf.($k[1])
    if ($ut) { $ut = [Environment]::ExpandEnvironmentVariables($ut) } else { $ut = Join-Path $env:USERPROFILE $k[2] }
    $hely = 'helyi'
    if ($ut.StartsWith('\\')) { $hely = 'halozaton' }
    elseif ($ut -match '^[A-Za-z]:') {
        $d = New-Object IO.DriveInfo($ut.Substring(0, 2))
        if ($d.DriveType -eq 'Network') { $hely = 'halozati meghajton' }
    }
    if ($hely -eq 'helyi' -and $ut -match '\\OneDrive') { $hely = 'OneDrive - szinkronizalt' }
    if ($hely -ne 'helyi') {
        if ($k[3]) { $szabvanyos += @{ ut = $ut; sor = ('{0,8}   {1}   - {2}' -f '-', $ut, ($k[0] + ', ' + $hely + ' - nem kell kezzel menteni')) } }
        continue
    }
    if (-not (Test-Path -LiteralPath $ut)) { continue }
    $szabvanyos += @{ ut = $ut; nev = $k[0]; mindig = $k[3] }
}

# 2. Nem szabvanyos mappak
$gyokerek = @(
    @{ ut = $env:SystemDrive + '\'; lista = ($env:ATNEZ_KIHAGY_C -split ';') },
    @{ ut = $env:USERPROFILE;       lista = ($env:ATNEZ_KIHAGY_PROFIL -split ';') }
)
$egyeb = @()
foreach ($g in $gyokerek) {
    Get-ChildItem -LiteralPath $g.ut -Directory -Force -ErrorAction SilentlyContinue | Where-Object {
        -not ($_.Attributes -band [IO.FileAttributes]::Hidden) -and
        -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -and
        -not $_.Name.StartsWith('.') -and
        -not (Kihagy $_.Name $g.lista)
    } | ForEach-Object { $egyeb += $_.FullName }
}

$meret = MerdMind (@($szabvanyos | Where-Object { -not $_.sor } | ForEach-Object { $_.ut }) + $egyeb)

$kimenet = New-Object System.Collections.Generic.List[string]
$listazott = New-Object System.Collections.Generic.List[string]
foreach ($s in $szabvanyos) {
    if ($s.sor) { $kimenet.Add($s.sor); continue }
    $b = $meret[$s.ut]
    if ($b -eq 0 -and -not $s.mindig) { continue }
    $megj = $s.nev + ', helyi - nincs a halozaton'
    if (VanPst $s.ut) { $megj += ', csatolt PST van benne' }
    $listazott.Add($s.ut)
    $kimenet.Add((Sor $b $s.ut $megj))
}
# A lemert mappak meret szerint csokkenoen, a nem lemertek a vegen
$talalat = @($egyeb | Where-Object { $meret[$_] -ne 0 } | ForEach-Object { New-Object PSObject -Property @{ ut = $_; meret = $meret[$_] } })
foreach ($t in ($talalat | Sort-Object @{ e = { if ($_.meret -lt 0) { 0 } else { 1 } }; Descending = $true }, @{ e = 'meret'; Descending = $true })) {
    $megj = 'nem szabvanyos mappa'
    if (VanPst $t.ut) { $megj += ', csatolt PST van benne' }
    $listazott.Add($t.ut)
    $kimenet.Add((Sor $t.meret $t.ut $megj))
}

# 3. Csatolt PST-k mappai, ha egyik fenti mappaban sincsenek
$pstMappak = $psts | ForEach-Object { Split-Path $_ -Parent } | Select-Object -Unique
foreach ($m in $pstMappak) {
    $benne = $false
    foreach ($l in $listazott) { if (($m.TrimEnd('\') + '\').StartsWith($l.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) { $benne = $true } }
    if (-not $benne) { $kimenet.Add(('{0,8}   {1}   - {2}' -f '-', $m, 'csatolt PST mappaja')) }
}
if ($allapot.lekeses) { $kimenet.Add('         A meres ' + $korlat + ' mp utan leallt - a tobbi mappa meretet nem merte.') }

foreach ($s in $kimenet) { '   ' + $s }
# A cmd a konzol kodlapjan olvassa vissza - UTF-8 eseten BOM nelkul
$kodolas = [Console]::OutputEncoding
if ($kodolas.CodePage -eq 65001) { $kodolas = New-Object Text.UTF8Encoding $false }
if ($env:ATN_KI) { [IO.File]::WriteAllLines($env:ATN_KI, $kimenet, $kodolas) }
