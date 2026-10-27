# ==========================================================
#  Outlook-lista - lib\outlook.cmd futtatja
#  Csak a registryt olvassa, az Outlookhoz nem nyul.
#  Bemenet:  OL_OUT  - a kimeneti szovegfajl
#            SRC_PST - a PST mappa, ami mentesre kerul
#            VERZIO, SZERZO - a fajl lablecehez
#  Kimenet:  KINT|<eleresi ut> soronkent a PST mappan kivuli PST-krol
#            SUM|<darab> a vegen
# ==========================================================
$ErrorActionPreference = 'SilentlyContinue'
$out = $env:OL_OUT; $pstDir = $env:SRC_PST.TrimEnd('\') + '\'

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
$L.Add('OUTLOOK-LISTA – ' + $env:USERNAME + ' / ' + $env:COMPUTERNAME + ' – ' + (Get-Date -Format 'yyyy. MM. dd. HH:mm'))
$L.Add('')
$L.Add('1. CSATOLT ADATFÁJLOK – PST, például archívum')
$L.Add('   Újra csatolás az új gépen: Fájl – Megnyitás és exportálás – Outlook-adatfájl megnyitása')
$kint = 0
if ($psts.Count -eq 0) { $L.Add('   – nincs csatolt PST') }
foreach ($p in $psts) {
    if ($p.StartsWith($pstDir, [StringComparison]::OrdinalIgnoreCase)) { $L.Add('   – ' + $p) }
    else { $kint++; $L.Add('   – ' + $p + '   FIGYELEM: nem a PST-mappában van, a segédlet nem mentette'); Write-Output ('KINT|' + $p) }
}
$L.Add('')
$L.Add('2. KÉZZEL ELLENŐRIZENDŐ A RÉGI GÉPEN – ezeket a segédlet nem menti')
$L.Add('   [ ] További postaládák: Fájl – Fiókbeállítások – Módosítás – További beállítások – Speciális')
$L.Add('       Az automatikusan csatolt postaládák maguktól visszajönnek.')
$L.Add('   [ ] Feladó mező: új levél – a Feladó gomb lenyíló listája; a többi címet írd fel')
$L.Add('   [ ] További fiókok: Fájl – Fiókbeállítások – E-mail lap')
$L.Add('')
$L.Add('Eszközcsere segédlet ' + $env:VERZIO + ' · Készítette: ' + $env:SZERZO)
$L | Out-File -LiteralPath $out -Encoding UTF8
Write-Output ('SUM|' + $psts.Count)
