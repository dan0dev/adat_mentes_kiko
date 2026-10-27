# ==========================================================
#  Outlook-lista - lib\outlook.cmd futtatja
#  Csak a registryt olvassa, az Outlookhoz nem nyul.
#  Rovid, kulcsszavas - a fajl neve (outlook_lista.txt) mar megmondja, mi ez.
#  Bemenet:  OL_OUT  - a kimeneti szovegfajl
#            SRC_PST - a PST mappa, ami mentesre kerul
#            VERZIO, SZERZO - a fajl lablecehez
#  Kimenet:  PST|<eleresi ut> minden csatolt PST-rol - ez latszik a kepernyon
#            SUM|<darab> a vegen
#  Nem figyelmeztet: a PST barhol lehet, csak a helye szamit.
# ==========================================================
$ErrorActionPreference = 'SilentlyContinue'
$out = $env:OL_OUT

# A csatolt PST-k utvonala a profilok 001f6700 erteke, Unicode szovegkent
$psts = New-Object System.Collections.Generic.List[string]
$roots = 'HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles',
         'HKCU:\Software\Microsoft\Office\15.0\Outlook\Profiles',
         'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles'
foreach ($r in $roots) {
    if (Test-Path $r) {
        Get-ChildItem -Path $r -Recurse | ForEach-Object {
            $v = $_.GetValue('001f6700')
            if ($v -is [byte[]]) {
                $p = [Text.Encoding]::Unicode.GetString($v).TrimEnd([char]0)
                if ($p -and -not $psts.Contains($p)) { $psts.Add($p) }
            }
        }
    }
}

$L = New-Object System.Collections.Generic.List[string]
$L.Add($env:USERNAME + ' · ' + $env:COMPUTERNAME + ' · ' + (Get-Date -Format 'yyyy. MM. dd.'))
$L.Add('')
$L.Add('PST – újra csatolni: Fájl › Megnyitás és exportálás › Outlook-adatfájl megnyitása')
if ($psts.Count -eq 0) { $L.Add('  – nincs') }
foreach ($p in $psts) {
    $L.Add('  – ' + $p)
    Write-Output ('PST|' + $p)
}
$L.Add('')
$L.Add('KÉZZEL – régi gépen')
$L.Add('[ ] További postaládák: Fiókbeállítások › Módosítás › További beállítások › Speciális')
$L.Add('[ ] Feladó címek: új levél › Feladó (az automatikus postaládák maguktól jönnek vissza)')
$L.Add('[ ] További fiókok: Fiókbeállítások › E-mail')
$L.Add('')
$L.Add('Eszközcsere segédlet ' + $env:VERZIO + ' · Készítette: ' + $env:SZERZO)
$L | Out-File -LiteralPath $out -Encoding UTF8
Write-Output ('SUM|' + $psts.Count)
