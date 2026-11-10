# ==========================================================
#  Kulso meghajto felismerese - lib\ellenorzes.cmd :MEGHAJTO futtatja
#  Csak olvas. Kulso: USB-n csatlakozo lemez (Get-Disk BusType, vagy Win32_DiskDrive
#  InterfaceType), cserelheto meghajto (pendrive), vagy amin mar van mentes mappa.
#  A rendszermeghajto sosem.
#  Bemenet:  MAPPA_NEV - a mentesek mappaja a meghajto gyokereben, pl. Mentes
#  Kimenet:  meghajtonkent egy sor: BETU|cimke|meret_GB|van_mentes (1/0) - cimke nelkul: -
#            elol az, amin mar van mentes
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

$talalt = foreach ($d in Get-CimInstance Win32_LogicalDisk) {
    $betu = $d.DeviceID
    if ($betu -eq $env:SystemDrive -or -not $d.Size) { continue }
    $mentes = [bool]($env:MAPPA_NEV -and (Test-Path -LiteralPath "$betu\$($env:MAPPA_NEV)"))
    if ($usb[$betu] -or $d.DriveType -eq 2 -or $mentes) {
        # Ures cimke helyett - : a cmd for /f-je az egymas melletti elvalasztokat osszevonja
        $cimke = ($d.VolumeName -replace '\|', ' ').Trim(); if (-not $cimke) { $cimke = '-' }
        [pscustomobject]@{ Betu = $betu.TrimEnd(':'); Cimke = $cimke; GB = [long][math]::Round($d.Size / 1GB); Mentes = $mentes }
    }
}
$talalt | Sort-Object @{ e = { -not $_.Mentes } }, Betu | ForEach-Object {
    $_.Betu + '|' + $_.Cimke + '|' + $_.GB + '|' + [int]$_.Mentes
}
