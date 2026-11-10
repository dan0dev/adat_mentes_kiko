# ==========================================================
#  A robocopy folyamatjelzo kimenetenek atalakitasa - lib\masolas.cmd futtatja
#  a lib\robo_prog.cmd kimenetet csovon at ide vezetve.
#  A robocopy /UNICODE kimenete a 65001-es konzolon: UTF-16 BOM, utana UTF-8 szoveg.
#  A BOM-ot eldobjuk, a tobbit UTF-8-kent olvassuk. A sorok a lepes behuzasat kapjak,
#  a " Log File :" sor es az ures sorok kimaradnak, a szazalekos haladas (a \r utan
#  ujrairt resz) elve marad.
#  Atugorhato masolas (R_ATU=1): a K billentyure leallitja a robocopy-t, torli a
#  felbemaradt fajlt, es letrehozza az R_ATF fajlt - ebbol tudja a masolas.cmd.
#  A billentyuzetet a $Host.UI.RawUI olvassa: a [Console] nem tudja, mert a
#  bemenet itt a cso.
# ==========================================================
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$beStream = [Console]::OpenStandardInput()
$dekoder = (New-Object Text.UTF8Encoding $false).GetDecoder()
$ki = [Console]::Out
$behuzas = '           '
$bajtok = New-Object byte[] 512
$puffer = New-Object char[] 1024
$sor = New-Object Text.StringBuilder
$kozvetlen = $false
$elso = $true
function Sor($t) {
    $t = $t.Replace("`t", '  ').TrimEnd()
    if ($t.Trim() -eq '' -or $t -match '^\s*Log File\s*:') { return $null }
    # A szazalek a behuzasnal jelenik meg (\r utan), a fajlnev ezert 7 oszloppal beljebb
    return $behuzas + '       ' + $t.TrimStart()
}

# ---------- Atugras ----------
# Hashtable, hogy a fuggvenyek modosithassak: a szkript szovegkent fut, a $script: itt nem megbizhato
$a = @{ figyel = ($env:R_ATU -eq '1'); raw = $null; kezdes = Get-Date }
if ($a.figyel) {
    # A korabban leutott billentyuk (pl. az "Indulhat?" valasz) ne szamitsanak
    try { $a.raw = $Host.UI.RawUI; while ($a.raw.KeyAvailable) { [void]$a.raw.ReadKey('NoEcho,IncludeKeyDown,IncludeKeyUp') } }
    catch { $a.figyel = $false }
}
function Kert {
    # $true, ha a K-t leutottek - a tobbi billentyut eldobja
    if (-not $a.figyel) { return $false }
    try {
        while ($a.raw.KeyAvailable) {
            $k = $a.raw.ReadKey('NoEcho,IncludeKeyDown,IncludeKeyUp')
            if ($k.KeyDown -and ([string]$k.Character).ToUpper() -eq 'K') { return $true }
        }
    } catch { $a.figyel = $false }
    return $false
}
function Atugras {
    $a.figyel = $false
    [IO.File]::WriteAllText($env:R_ATF, '1')
    # Csak ezt a robocopy-t: a parancssoraban benne van a sajat naplofajlja
    $robo = @(Get-CimInstance Win32_Process -Filter "Name='robocopy.exe'" |
        Where-Object { $_.CommandLine -and $_.CommandLine.Contains($env:R_LOGT) })
    # A masolas kezdete a robocopy indulasa - ez a PowerShell elott indul el
    $kezdes = $a.kezdes
    foreach ($p in $robo) {
        if ($p.CreationDate -and $p.CreationDate -lt $kezdes) { $kezdes = $p.CreationDate }
        Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
        Wait-Process -Id $p.ProcessId -Timeout 10 -ErrorAction SilentlyContinue
    }
    # FAT/exFAT meghajton a fajlido kerekitett
    $kezdes = $kezdes.AddSeconds(-2)
    # A felbemaradt fajl: a robocopy elore lefoglalja a teljes meretet, es az idejet csak
    # a vegen allitja a forraseval egyezore. Ami tehat a masolas kozben irodott, es az ideje
    # elter a forrasetol, az felbemaradt - a celmappa tobbi fajljahoz nem nyulunk.
    $cel = $env:R_DST.TrimEnd('\'); $forras = $env:R_SRC.TrimEnd('\')
    if (-not (Test-Path -LiteralPath $cel)) { return }
    $felbe = @(Get-ChildItem -LiteralPath $cel -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -ge $kezdes } | Where-Object {
            $f = Get-Item -LiteralPath ($forras + $_.FullName.Substring($cel.Length)) -Force -ErrorAction SilentlyContinue
            $f -and $f.LastWriteTime -ne $_.LastWriteTime
        })
    # A leallitott robocopy a fajlt meg egy pillanatig fogja - par masodpercig ujraprobaljuk
    foreach ($x in $felbe) {
        for ($i = 0; $i -lt 40; $i++) {
            try { Remove-Item -LiteralPath $x.FullName -Force -ErrorAction Stop; break }
            catch { Start-Sleep -Milliseconds 250 }
        }
    }
}
function Olvas {
    if (-not $a.figyel) { return $beStream.Read($bajtok, 0, $bajtok.Length) }
    if (Kert) { Atugras | Out-Null }
    # Aszinkron olvasas, hogy a billentyut akkor is lassuk, ha a robocopy eppen nem ir
    $t = $beStream.ReadAsync($bajtok, 0, $bajtok.Length)
    while (-not $t.Wait(200)) { if (Kert) { Atugras | Out-Null } }
    return $t.Result
}

while (($nb = Olvas) -gt 0) {
    $kezd = 0
    if ($elso) { $elso = $false; if ($nb -ge 2 -and $bajtok[0] -eq 0xFF -and $bajtok[1] -eq 0xFE) { $kezd = 2 } }
    $n = $dekoder.GetChars($bajtok, $kezd, $nb - $kezd, $puffer, 0)
    for ($i = 0; $i -lt $n; $i++) {
        $c = $puffer[$i]
        if ($c -eq "`r") {
            if (-not $kozvetlen) {
                $t = Sor $sor.ToString(); [void]$sor.Clear()
                if ($t -ne $null) { $ki.Write($t) }
                $kozvetlen = $true
            }
            $ki.Write("`r" + $behuzas)
        }
        elseif ($c -eq "`n") {
            if ($kozvetlen) { $ki.Write("`n") }
            else {
                $t = Sor $sor.ToString(); [void]$sor.Clear()
                if ($t -ne $null) { $ki.Write($t + "`n") }
            }
            $kozvetlen = $false
        }
        elseif ($c -eq [char]0xFEFF) { }
        elseif ($kozvetlen) { if ($c -eq "`t") { $ki.Write('  ') } else { $ki.Write($c) } }
        else { [void]$sor.Append($c) }
    }
    $ki.Flush()
}
if ($sor.Length) { $t = Sor $sor.ToString(); if ($t -ne $null) { $ki.Write($t + "`n") } }
# Leallitott robocopy utan a szazalekos sor nyitva marad
if ($kozvetlen) { $ki.Write("`n") }
$ki.Flush()
