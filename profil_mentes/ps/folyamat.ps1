# ==========================================================
#  A robocopy folyamatjelzo kimenetenek atalakitasa - lib\masolas.cmd futtatja
#  a lib\robo_prog.cmd kimenetet csovon at ide vezetve.
#  A robocopy /UNICODE kimenete a 65001-es konzolon: UTF-16 BOM, utana UTF-8 szoveg.
#  A BOM-ot eldobjuk, a tobbit UTF-8-kent olvassuk. A sorok a lepes behuzasat kapjak,
#  a " Log File :" sor es az ures sorok kimaradnak, a szazalekos haladas (a \r utan
#  ujrairt resz) elve marad.
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
while (($nb = $beStream.Read($bajtok, 0, $bajtok.Length)) -gt 0) {
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
$ki.Flush()
