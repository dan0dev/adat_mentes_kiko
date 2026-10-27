# ==========================================================
#  A talcara rogzitett ikonok listaja - lib\talca.cmd futtatja
#  Csak olvas. Bemenet: TALCA_FAJL - a kimeneti fajl, VERZIO, SZERZO - a lablechez
#  Kimenet: a talalt ikonok szama
#  Asztali programok: .lnk a User Pinned\TaskBar mappaban.
#  Store appok: az azonositojuk a Taskband Favorites ertekeben van,
#  a nevuket a Get-StartApps adja.
# ==========================================================
$ErrorActionPreference = 'Stop'
$tb = Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'
$L = New-Object System.Collections.Generic.List[string]
$L.Add('A TÁLCÁRA RÖGZÍTETT IKONOK – ' + $env:USERNAME + ' / ' + $env:COMPUTERNAME + ' – ' + (Get-Date -Format 'yyyy. MM. dd. HH:mm'))
$L.Add('Újra rögzítés az új gépen: Start – keresd meg a programot – jobb kattintás – Rögzítés a tálcára')
$L.Add('')
$db = 0

if (Test-Path -LiteralPath $tb) {
    Get-ChildItem -LiteralPath $tb -Filter *.lnk -File -Force | Sort-Object Name | ForEach-Object {
        $L.Add('   – ' + $_.BaseName); $db++
    }
}

$fav = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband' -Name Favorites -ErrorAction SilentlyContinue).Favorites
if ($fav) {
    $ids = [regex]::Matches([Text.Encoding]::Unicode.GetString($fav), '[A-Za-z0-9.\-]+_[a-z0-9]{13}![A-Za-z0-9.\-]+') |
           ForEach-Object { $_.Value } | Select-Object -Unique
    if ($ids) {
        $nevek = @{}
        try { Get-StartApps | ForEach-Object { $nevek[$_.AppID] = $_.Name } } catch { }
        foreach ($id in $ids) {
            $n = $nevek[$id]; if (-not $n) { $n = $id }
            $L.Add('   – ' + $n + '   (Store-alkalmazás)'); $db++
        }
    }
}

if ($db -eq 0) { $L.Add('   – nincs rögzített ikon') }
$L.Add('')
$L.Add('Eszközcsere segédlet ' + $env:VERZIO + ' · Készítette: ' + $env:SZERZO)
$L | Out-File -LiteralPath $env:TALCA_FAJL -Encoding UTF8
Write-Output $db
