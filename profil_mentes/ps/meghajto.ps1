# ==========================================================
#  Kulso meghajto felismerese - lib\ellenorzes.cmd :MEGHAJTO futtatja
#  Csak olvas. Kulso: USB-n csatlakozo lemez (Get-Disk BusType, vagy Win32_DiskDrive
#  InterfaceType) vagy cserelheto meghajto (pendrive). A rendszermeghajto sosem.
#  Amin a segedlet mentese van, az is a listara kerul - de attol meg NEM kulso: egy belso
#  D:\Mentes mappa miatt a mentes nem kerulhet kerdes nelkul a regi gep sajat lemezere.
#  Mentesnek csak az szamit, amit a segedlet irt: a mentes mappa egy almappajaban ott a
#  naplo vagy a teendok fajlja - egy sajat, "Mentes" nevu mappa nem.
#  Bemenet:  MAPPA_NEV - a mentesek mappaja a meghajto gyokereben, pl. Mentes
#  Kimenet:  meghajtonkent egy sor: BETU|cimke|meret_GB|van_mentes (1/0)|kulso (1/0)
#            cimke nelkul: - ; elol a kulsok, azon belul az, amin mar van mentes
# ==========================================================
$ErrorActionPreference = 'SilentlyContinue'
$usb = @{}
# USB-s lemezek betujelei - a Get-Disk az UASP-s (SCSI-nek latszo) USB-s SSD-t is felismeri
try {
    Get-Disk | Where-Object BusType -eq 'USB' | ForEach-Object {
        Get-Partition -DiskNumber $_.Number | Where-Object DriveLetter | ForEach-Object { $usb[[string]$_.DriveLetter + ':'] = $true }
    }
} catch { }
try {
    Get-CimInstance Win32_DiskDrive -Filter "InterfaceType='USB'" | ForEach-Object {
        Get-CimAssociatedInstance -InputObject $_ -ResultClassName Win32_DiskPartition | ForEach-Object {
            Get-CimAssociatedInstance -InputObject $_ -ResultClassName Win32_LogicalDisk | ForEach-Object { $usb[$_.DeviceID] = $true }
        }
    }
} catch { }

# A segedlet irta fajlok egy mentesben - a regi valtozat nevei is
$jelzok = 'mentes_naplo.txt', '_TEENDOK.txt', 'mentes_log.txt', '_LEFT-TO-DO.txt'
$talalt = foreach ($d in Get-CimInstance Win32_LogicalDisk) {
    $betu = $d.DeviceID
    if ($betu -eq $env:SystemDrive -or -not $d.Size) { continue }
    $mentes = $false
    if ($env:MAPPA_NEV) {
        $mentes = [bool](Get-ChildItem -LiteralPath "$betu\$($env:MAPPA_NEV)" -Directory | Where-Object {
            $m = $_.FullName
            @($jelzok | Where-Object { Test-Path -LiteralPath (Join-Path $m $_) }).Count
        } | Select-Object -First 1)
    }
    $kulso = [bool]($usb[$betu] -or $d.DriveType -eq 2)
    if ($kulso -or $mentes) {
        # Ures cimke helyett - : a cmd for /f-je az egymas melletti elvalasztokat osszevonja
        $cimke = ($d.VolumeName -replace '\|', ' ').Trim(); if (-not $cimke) { $cimke = '-' }
        [pscustomobject]@{ Betu = $betu.TrimEnd(':'); Cimke = $cimke; GB = [long][math]::Round($d.Size / 1GB); Mentes = $mentes; Kulso = $kulso }
    }
}
$talalt | Sort-Object @{ e = { -not $_.Kulso } }, @{ e = { -not $_.Mentes } }, Betu | ForEach-Object {
    $_.Betu + '|' + $_.Cimke + '|' + $_.GB + '|' + [int]$_.Mentes + '|' + [int]$_.Kulso
}
