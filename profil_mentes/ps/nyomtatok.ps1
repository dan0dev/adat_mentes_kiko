# ==========================================================
#  Nyomtatok es halozati meghajtok listaja - lib\nyomtatok.cmd futtatja
#  Csak olvas. Ami a csoportharendbol jon, az az uj gepen magatol visszajon -
#  a lista a kezzel felvettekhez kell.
#  Bemenet:  NY_FAJL - a kimeneti fajl, VERZIO, SZERZO - a lablechez
#  Kimenet:  nyomtatok_szama|meghajtok_szama
# ==========================================================
$ErrorActionPreference = 'SilentlyContinue'
$L = New-Object System.Collections.Generic.List[string]
$L.Add($env:USERNAME + ' · ' + $env:COMPUTERNAME + ' · ' + (Get-Date -Format 'yyyy. MM. dd.'))
$L.Add('Ami a céges beállításból jön, az magától visszajön – csak ami hiányzik, azt vedd fel.')
$L.Add('')

# Nyomtatok - a virtualisak (PDF, XPS, OneNote, fax) nelkul
$virtualis = 'Microsoft Print to PDF|Microsoft XPS|OneNote|Fax|Send To|Adobe PDF'
$ny = @(Get-CimInstance Win32_Printer | Where-Object { $_.Name -notmatch $virtualis } | Sort-Object Name)
$L.Add('NYOMTATÓK – újra: Gépház › Bluetooth és eszközök › Nyomtatók és szkennerek')
if ($ny.Count -eq 0) { $L.Add('  – nincs') }
foreach ($p in $ny) {
    $hol = if ($p.Network -or $p.Name -like '\\*') { 'hálózati' } else { 'helyi, port: ' + $p.PortName }
    $alap = if ($p.Default) { ' (alapértelmezett)' } else { '' }
    $L.Add('  – ' + $p.Name + $alap + ' – ' + $hol)
}
$L.Add('')

# Halozati meghajtok - a tartosan csatoltak (HKCU\Network)
$mh = @(Get-ChildItem 'HKCU:\Network' | ForEach-Object {
    [pscustomobject]@{ Betu = $_.PSChildName.ToUpper(); Ut = (Get-ItemProperty $_.PSPath).RemotePath }
} | Where-Object Ut | Sort-Object Betu)
$L.Add('HÁLÓZATI MEGHAJTÓK – újra: Fájlkezelő › Ez a gép › Hálózati meghajtó csatlakoztatása')
if ($mh.Count -eq 0) { $L.Add('  – nincs') }
foreach ($m in $mh) { $L.Add('  – ' + $m.Betu + ':  ' + $m.Ut) }
$L.Add('')
$L.Add('Eszközcsere segédlet ' + $env:VERZIO + ' · Készítette: ' + $env:SZERZO)
[IO.File]::WriteAllLines($env:NY_FAJL, [string[]]$L, (New-Object Text.UTF8Encoding $false))
'{0}|{1}' -f $ny.Count, $mh.Count
