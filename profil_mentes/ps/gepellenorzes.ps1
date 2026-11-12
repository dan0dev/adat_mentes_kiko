<#
.SYNOPSIS
    Teljesítmény- és hőellenőrzés (laptop / PC) – az eredmény logfájlba mentve.

.DESCRIPTION
    Pillanatképet készít a gép állapotáról:
      1. Gépadatok, BIOS, uptime, függőben lévő újraindítás
      2. Hőmérséklet (ACPI hőzónák)
      3. CPU: össz-terhelés, aktuális órajel, top 5 CPU-terhelő folyamat
      4. Memória: kihasználtság, top 5 RAM-fogyasztó program
      5. Lemez: szabad hely, típus (SSD/HDD), állapot, aktivitás
      6. Energiaséma, Windows energiamód, min/max processzorállapot
      7. Akkumulátor: töltöttség, kopás, battery report (HTML)
      8. Automatikusan induló programok
      9. Eseménynapló: CPU-fojtás, váratlan leállás, kékhalál, lemezhibák
     10. (opcionális) Megfigyelés: X percig méri a hőt és terhelést, CSV-be is

    Rendszergazdaként futtatva több adatot lát (pl. hőszenzor, akkukopás).

.PARAMETER LogDir
    Ide kerül a log, a battery report és a CSV. Alapértelmezés: C:\Temp\GepEllenorzes
    (a segédlet 7. menüpontjából: naplok\gepellenorzes a profil_mentes mellett)

.PARAMETER MonitorPerc
    Ha nagyobb mint 0, ennyi percig figyeli a gépet a pillanatkép után.

.PARAMETER IntervalMp
    Megfigyeléskor ennyi másodpercenként mér. Alapértelmezés: 30

.EXAMPLE
    .\GepEllenorzes.ps1
    .\GepEllenorzes.ps1 -MonitorPerc 10 -IntervalMp 20
#>
[CmdletBinding()]
param(
    # A segedletbol inditva a GE_NAPLOK adja: a naplok\gepellenorzes mappa a profil_mentes mellett
    [string]$LogDir = $(if ($env:GE_NAPLOK) { $env:GE_NAPLOK } else { 'C:\Temp\GepEllenorzes' }),
    [int]$MonitorPerc = 0,
    [int]$IntervalMp = 30
)

$ErrorActionPreference = 'SilentlyContinue'

# =====================================================================
#  Előkészítés, segédfüggvények
# =====================================================================
$stamp   = Get-Date -Format 'yyyyMMdd_HHmmss'
$gepNev  = $env:COMPUTERNAME
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
$LogFile = Join-Path $LogDir "${gepNev}_${stamp}.log"
$Figyelmeztetesek = New-Object System.Collections.Generic.List[string]
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)

function Write-Log {
    param([string]$Szoveg = '', [ConsoleColor]$Szin = 'Gray')
    Write-Host $Szoveg -ForegroundColor $Szin
    Add-Content -Path $LogFile -Value $Szoveg -Encoding UTF8
}

function Write-Szakasz([string]$Cim) {
    Write-Log ''
    Write-Log ('=' * 72) 'DarkCyan'
    Write-Log "  $Cim" 'Cyan'
    Write-Log ('=' * 72) 'DarkCyan'
}

function Add-Figyelmeztetes([string]$Szoveg, [switch]$Kritikus) {
    $elotag = if ($Kritikus) { '[KRITIKUS]' } else { '[!]' }
    $Figyelmeztetesek.Add("$elotag $Szoveg")
    $szin = if ($Kritikus) { 'Red' } else { 'Yellow' }
    Write-Log "  $elotag $Szoveg" $szin
}

function Write-Tabla($Adat) {
    if (-not $Adat) { return }
    $szoveg = ($Adat | Format-Table -AutoSize | Out-String -Width 220).Trim("`r", "`n")
    Write-Log $szoveg
}

function Get-Homersekletek {
    $eredmeny = @()
    # 1) ACPI hőzónák (általában rendszergazdai jog kell hozzá)
    try {
        $zonak = Get-CimInstance -Namespace 'root/wmi' -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop
        foreach ($z in $zonak) {
            $eredmeny += [pscustomobject]@{
                'Zóna'   = ($z.InstanceName -split '\\')[-1]
                'Celsius' = [math]::Round(($z.CurrentTemperature / 10) - 273.15, 1)
                'Forrás'  = 'MSAcpi (WMI)'
            }
        }
    } catch {}
    # 2) Tartalék: teljesítményszámláló (sima felhasználóként is működik)
    if (-not $eredmeny) {
        try {
            $zonak = Get-CimInstance -ClassName Win32_PerfFormattedData_Counters_ThermalZoneInformation -ErrorAction Stop
            foreach ($z in $zonak) {
                $kelvin = if ($z.HighPrecisionTemperature) { $z.HighPrecisionTemperature / 10 } else { $z.Temperature }
                $eredmeny += [pscustomobject]@{
                    'Zóna'    = ($z.Name -split '\\')[-1]
                    'Celsius' = [math]::Round($kelvin - 273.15, 1)
                    'Forrás'  = 'Perf számláló'
                }
            }
        } catch {}
    }
    # Értelmetlen értékek kiszűrése
    $eredmeny | Where-Object { $_.Celsius -gt 0 -and $_.Celsius -lt 125 }
}

function Get-FolyamatMinta([int]$Mp = 5) {
    # A CPU-használatot két mérés különbségéből számolja (nyelvfüggetlen, magyar Windowson is jó)
    $magok  = [Environment]::ProcessorCount
    $elotte = @{}
    foreach ($p in Get-Process) {
        try { if ($p.TotalProcessorTime) { $elotte[$p.Id] = $p.TotalProcessorTime.TotalMilliseconds } } catch {}
    }
    $ora = [Diagnostics.Stopwatch]::StartNew()
    Start-Sleep -Seconds $Mp
    $eltelt = $ora.Elapsed.TotalMilliseconds
    foreach ($p in Get-Process) {
        try {
            if ($p.TotalProcessorTime -and $elotte.ContainsKey($p.Id)) {
                $delta = $p.TotalProcessorTime.TotalMilliseconds - $elotte[$p.Id]
                [pscustomobject]@{
                    Folyamat = $p.ProcessName
                    PID      = $p.Id
                    'CPU %'  = [math]::Round(($delta / ($eltelt * $magok)) * 100, 1)
                    'RAM MB' = [math]::Round($p.WorkingSet64 / 1MB)
                    Obj      = $p
                }
            }
        } catch {}
    }
}

function Get-PowercfgErtek([string]$Alcsoport, [string]$Beallitas) {
    # A powercfg kimenete nyelvfüggő, de az utolsó két hexa érték mindig: AC, DC
    $ki  = (powercfg /query SCHEME_CURRENT $Alcsoport $Beallitas 2>$null) -join "`n"
    $hex = @([regex]::Matches($ki, '0x[0-9a-fA-F]{8}') | ForEach-Object { [Convert]::ToInt32($_.Value, 16) })
    if ($hex.Count -ge 2) { [pscustomobject]@{ AC = $hex[-2]; DC = $hex[-1] } }
}

function Get-Esemenyek([hashtable]$Szuro) {
    try { @(Get-WinEvent -FilterHashtable $Szuro -ErrorAction Stop) } catch { @() }
}

# Gyakori "gyanúsítottak" magyarázata
$IsmertFolyamatok = @{
    'MsMpEng'            = 'Defender víruskeresés – általában átmeneti'
    'MsSense'            = 'Defender for Endpoint – biztonsági ügynök'
    'TiWorker'           = 'Windows Update telepítés – frissítés után megszűnik'
    'TrustedInstaller'   = 'Windows Update / összetevő telepítés'
    'SearchIndexer'      = 'Windows keresés indexelés'
    'SearchProtocolHost' = 'Windows keresés indexelés'
    'WmiPrvSE'           = 'WMI – gyakran felügyeleti szoftver kérdezi folyamatosan'
    'CcmExec'            = 'SCCM/ConfigMgr kliens – telepítés vagy leltár fut'
    'Teams'              = 'Teams – videóhívás, háttérelmosás erősen terhel'
    'ms-teams'           = 'Teams – videóhívás, háttérelmosás erősen terhel'
    'chrome'             = 'Böngésző – beragadt fül? (Shift+Esc: böngésző feladatkezelő)'
    'msedge'             = 'Böngésző – beragadt fül? (Shift+Esc: böngésző feladatkezelő)'
    'firefox'            = 'Böngésző – beragadt fül?'
    'System'             = 'Kernel/illesztőprogram – tartósan magas: driverprobléma gyanú'
    'dwm'                = 'Asztalkezelő – tartósan magas: grafikus driver gyanú'
    'audiodg'            = 'Hangmotor – tartósan magas: hangdriver/hangjavító gyanú'
}

# =====================================================================
#  1. GÉPADATOK
# =====================================================================
Write-Log "TELJESÍTMÉNY- ÉS HŐELLENŐRZÉS – $gepNev – $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" 'White'
Write-Szakasz '1. GÉPADATOK'

$cs     = Get-CimInstance Win32_ComputerSystem
$bios   = Get-CimInstance Win32_BIOS
$os     = Get-CimInstance Win32_OperatingSystem
$cpu    = Get-CimInstance Win32_Processor | Select-Object -First 1
$uptime = (Get-Date) - $os.LastBootUpTime

Write-Log ("  Gép:            {0}" -f $gepNev)
Write-Log ("  Felhasználó:    {0}\{1}" -f $env:USERDOMAIN, $env:USERNAME)
Write-Log ("  Gyártó/típus:   {0} {1}" -f $cs.Manufacturer, $cs.Model)
Write-Log ("  Sorozatszám:    {0}" -f $bios.SerialNumber)
Write-Log ("  BIOS:           {0} ({1:yyyy-MM-dd})" -f $bios.SMBIOSBIOSVersion, $bios.ReleaseDate)
Write-Log ("  Windows:        {0} (build {1})" -f $os.Caption, $os.BuildNumber)
Write-Log ("  Processzor:     {0} ({1} mag / {2} szál)" -f $cpu.Name.Trim(), $cpu.NumberOfCores, $cpu.NumberOfLogicalProcessors)
Write-Log ("  RAM:            {0:N1} GB" -f ($cs.TotalPhysicalMemory / 1GB))
Write-Log ("  Utolsó indítás: {0:yyyy-MM-dd HH:mm} (uptime: {1} nap {2} óra)" -f $os.LastBootUpTime, $uptime.Days, $uptime.Hours)
Write-Log ("  Rendszergazda:  {0}" -f $(if ($IsAdmin) { 'igen' } else { 'nem – néhány adat hiányozhat' }))

if ($uptime.TotalDays -ge 7) {
    Add-Figyelmeztetes ("A gép {0} napja nem volt újraindítva. Újraindítás javasolt (nem leállítás – a Gyorsindítás miatt a leállítás nem nulláz)." -f $uptime.Days)
}
if ($bios.ReleaseDate -and $bios.ReleaseDate -lt (Get-Date).AddYears(-2)) {
    Add-Figyelmeztetes 'A BIOS több mint 2 éves. A gyártói BIOS-frissítés gyakran javít a ventilátorvezérlésen és energiakezelésen.'
}

$fuggo = @()
if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') { $fuggo += 'Windows-összetevők (CBS)' }
if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') { $fuggo += 'Windows Update' }
if ($fuggo) {
    Add-Figyelmeztetes ("Függőben lévő újraindítás: {0}. Amíg nincs újraindítva, a háttérfolyamatok terhelhetik a gépet." -f ($fuggo -join ', '))
}

# =====================================================================
#  2. HŐMÉRSÉKLET
# =====================================================================
Write-Szakasz '2. HŐMÉRSÉKLET'
$homersekletek = @(Get-Homersekletek)
if ($homersekletek.Count -eq 0) {
    Write-Log '  A gép nem ad ki hőadatot WMI-n keresztül (vagy rendszergazdai jog kell).' 'Yellow'
    Write-Log '  Alternatíva: HWiNFO / Core Temp, vagy a gyártó diagnosztikája (HP: F2, Dell: F12, Lenovo: Vantage).'
} else {
    Write-Tabla $homersekletek
    $maxHo = ($homersekletek | Measure-Object Celsius -Maximum).Maximum
    if ($maxHo -ge 90) {
        Add-Figyelmeztetes ("Kritikus hőmérséklet: {0} °C. A CPU ilyenkor már visszafogja magát (throttling)." -f $maxHo) -Kritikus
    } elseif ($maxHo -ge 80) {
        Add-Figyelmeztetes ("Magas hőmérséklet: {0} °C. Terhelés alatt még belefér, alapjáraton nem normális." -f $maxHo)
    } else {
        Write-Log ("  Legmagasabb érték: {0} °C – rendben." -f $maxHo) 'Green'
    }
    Write-Log '  Megj.: ez ACPI hőzóna, nem mindig a CPU-mag hője. Ha minden futtatáskor ugyanaz' 'DarkGray'
    Write-Log '  az érték (pl. 27,8 °C), a gyártó nem ad valós adatot – ilyenkor HWiNFO kell.' 'DarkGray'
}

# =====================================================================
#  3. CPU ÉS FOLYAMATOK
# =====================================================================
Write-Szakasz '3. PROCESSZOR – terhelés és top 5 folyamat'
Write-Log '  Mérés 5 másodpercig...' 'DarkGray'

# A formázott perf-osztályok első lekérdezése gyakran 0-t ad, ezért előtte "felébresztjük" őket
$null = Get-CimInstance Win32_PerfFormattedData_Counters_ProcessorInformation -Filter "Name='_Total'"
$null = Get-CimInstance Win32_PerfFormattedData_PerfDisk_PhysicalDisk -Filter "Name='_Total'"

$minta = @(Get-FolyamatMinta -Mp 5)

$cpuTerheles = [math]::Round((Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average)
$procInfo    = Get-CimInstance Win32_PerfFormattedData_Counters_ProcessorInformation -Filter "Name='_Total'"

Write-Log ("  Össz-CPU-terhelés: {0}%" -f $cpuTerheles)
if ($procInfo -and $procInfo.PercentProcessorPerformance -gt 0 -and $procInfo.ProcessorFrequency -gt 0) {
    $aktMhz = [math]::Round($procInfo.ProcessorFrequency * $procInfo.PercentProcessorPerformance / 100)
    Write-Log ("  Aktuális órajel:   kb. {0} MHz (névleges: {1} MHz, {2}%)" -f $aktMhz, $procInfo.ProcessorFrequency, $procInfo.PercentProcessorPerformance)
    if ($cpuTerheles -ge 50 -and $procInfo.PercentProcessorPerformance -lt 60) {
        Add-Figyelmeztetes 'Terhelés alatt is alacsony az órajel – hő- vagy tápfojtás (throttling) gyanú.'
    }
}
if ($cpuTerheles -ge 80) {
    Add-Figyelmeztetes ("Nagyon magas össz-CPU-terhelés: {0}%." -f $cpuTerheles)
}

$topCpu = $minta | Sort-Object 'CPU %' -Descending | Select-Object -First 5
$topCpuKiir = foreach ($t in $topCpu) {
    $leiras = $null
    try { $leiras = $t.Obj.Description } catch {}
    if ($t.Folyamat -eq 'svchost') {
        $szolg = (Get-CimInstance Win32_Service -Filter "ProcessId=$($t.PID)" | Select-Object -ExpandProperty Name) -join ', '
        if ($szolg) { $leiras = "Szolgáltatás: $szolg" }
    }
    if ($leiras -and $leiras.Length -gt 55) { $leiras = $leiras.Substring(0, 52) + '...' }
    [pscustomobject]@{
        Folyamat = $t.Folyamat
        PID      = $t.PID
        'CPU %'  = $t.'CPU %'
        'RAM MB' = $t.'RAM MB'
        'Leírás' = $leiras
    }
}
Write-Log ''
Write-Tabla $topCpuKiir

foreach ($t in $topCpu) {
    if ($t.'CPU %' -ge 25) {
        $tipp = $IsmertFolyamatok[$t.Folyamat]
        $szoveg = "{0} (PID {1}) {2}% CPU-t használ." -f $t.Folyamat, $t.PID, $t.'CPU %'
        if ($tipp) { $szoveg += " Tipp: $tipp" }
        Add-Figyelmeztetes $szoveg
    } elseif ($IsmertFolyamatok.ContainsKey($t.Folyamat) -and $t.'CPU %' -ge 5) {
        Write-Log ("  i  {0}: {1}" -f $t.Folyamat, $IsmertFolyamatok[$t.Folyamat]) 'DarkGray'
    }
}

# =====================================================================
#  4. MEMÓRIA
# =====================================================================
Write-Szakasz '4. MEMÓRIA'
$osszMB   = [math]::Round($os.TotalVisibleMemorySize / 1KB)
$szabadMB = [math]::Round($os.FreePhysicalMemory / 1KB)
$hasznPct = [math]::Round((1 - $os.FreePhysicalMemory / $os.TotalVisibleMemorySize) * 100)
Write-Log ("  Használt: {0:N1} GB / {1:N1} GB ({2}%)" -f (($osszMB - $szabadMB) / 1024), ($osszMB / 1024), $hasznPct)

if ($hasznPct -ge 90) {
    Add-Figyelmeztetes ("A memória {0}%-ban tele – a gép lapozófájlt használ, ez nagyon lassít." -f $hasznPct) -Kritikus
} elseif ($hasznPct -ge 80) {
    Add-Figyelmeztetes ("Magas memóriahasználat: {0}%." -f $hasznPct)
}
if ($osszMB -lt 7500) {
    Add-Figyelmeztetes ("Kevés a RAM ({0:N0} GB) – mai irodai használathoz (Teams, böngésző) min. 8, inkább 16 GB ajánlott." -f ($osszMB / 1024))
}

Write-Log ''
Write-Log '  Top 5 RAM-fogyasztó program (azonos nevű folyamatok összesítve):'
$topRam = Get-Process | Group-Object ProcessName | ForEach-Object {
    [pscustomobject]@{
        Program    = $_.Name
        'Példány'  = $_.Count
        'RAM MB'   = [math]::Round((($_.Group | Measure-Object WorkingSet64 -Sum).Sum) / 1MB)
    }
} | Sort-Object 'RAM MB' -Descending | Select-Object -First 5
Write-Tabla $topRam

# =====================================================================
#  5. LEMEZ
# =====================================================================
Write-Szakasz '5. LEMEZ'
$cMeghajto = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
if ($cMeghajto) {
    $szabadGB = [math]::Round($cMeghajto.FreeSpace / 1GB, 1)
    $meretGB  = [math]::Round($cMeghajto.Size / 1GB, 1)
    $szabadPct = [math]::Round($cMeghajto.FreeSpace / $cMeghajto.Size * 100)
    Write-Log ("  C: meghajtó: {0} GB szabad / {1} GB ({2}%)" -f $szabadGB, $meretGB, $szabadPct)
    if ($szabadGB -lt 10 -or $szabadPct -lt 10) {
        Add-Figyelmeztetes ("Kevés a szabad hely a C:-n ({0} GB). Ez lassítja a frissítéseket és a lapozást." -f $szabadGB) -Kritikus
    }
}

$fizikai = Get-PhysicalDisk | Select-Object FriendlyName, MediaType, BusType, HealthStatus,
    @{ n = 'Méret GB'; e = { [math]::Round($_.Size / 1GB) } }
if ($fizikai) {
    Write-Log ''
    Write-Tabla $fizikai
    foreach ($d in $fizikai) {
        if ($d.MediaType -eq 'HDD') {
            Add-Figyelmeztetes ("'{0}' hagyományos HDD – ez a legtöbb lassúság oka, SSD-csere javasolt." -f $d.FriendlyName)
        }
        if ($d.HealthStatus -and $d.HealthStatus -ne 'Healthy') {
            Add-Figyelmeztetes ("'{0}' állapota: {1}. Adatmentés és lemezcsere javasolt!" -f $d.FriendlyName, $d.HealthStatus) -Kritikus
        }
    }
}

$lemezPerf = Get-CimInstance Win32_PerfFormattedData_PerfDisk_PhysicalDisk -Filter "Name='_Total'"
if ($lemezPerf -and $null -ne $lemezPerf.PercentIdleTime) {
    $aktiv = [math]::Max(0, 100 - [int]$lemezPerf.PercentIdleTime)
    Write-Log ("  Lemezaktivitás most: {0}% (várakozási sor: {1})" -f $aktiv, $lemezPerf.CurrentDiskQueueLength)
    if ($aktiv -ge 90) {
        Add-Figyelmeztetes 'A lemez közel 100%-on pörög – a gép emiatt "akadhat", még ha a CPU nincs is terhelve.'
    }
}

# =====================================================================
#  6. ENERGIAGAZDÁLKODÁS
# =====================================================================
Write-Szakasz '6. ENERGIAGAZDÁLKODÁS'
$semaSor = (powercfg /getactivescheme) -join ' '
$semaGuid = [regex]::Match($semaSor, '[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}').Value.ToLower()
$semaNev  = [regex]::Match($semaSor, '\((.+)\)').Groups[1].Value
$ismertSemak = @{
    '381b4222-f694-41f0-9685-ff5bb260df2e' = 'Kiegyensúlyozott (Balanced)'
    '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' = 'Nagy teljesítményű (High performance)'
    'e9a42b02-d5df-448d-aa00-03f14749eb61' = 'Ultimate Performance'
    'a1841308-3541-4fab-bc81-f71556f20b4a' = 'Energiatakarékos (Power saver)'
}
$semaTipus = if ($ismertSemak.ContainsKey($semaGuid)) { $ismertSemak[$semaGuid] } else { 'egyedi / gyártói séma' }
Write-Log ("  Aktív séma: {0} – {1}" -f $semaNev, $semaTipus)
Write-Log ("  GUID:       {0}" -f $semaGuid) 'DarkGray'

if ($semaGuid -in @('8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c', 'e9a42b02-d5df-448d-aa00-03f14749eb61')) {
    Add-Figyelmeztetes 'Teljesítménycentrikus energiaséma aktív – a CPU feleslegesen magas órajelen jár, ez melegít. Javasolt: Kiegyensúlyozott (powercfg /setactive SCHEME_BALANCED).'
}

$minAllapot = Get-PowercfgErtek 'SUB_PROCESSOR' 'PROCTHROTTLEMIN'
$maxAllapot = Get-PowercfgErtek 'SUB_PROCESSOR' 'PROCTHROTTLEMAX'
if ($minAllapot) {
    Write-Log ("  Min. processzorállapot: hálózat {0}% / akku {1}%" -f $minAllapot.AC, $minAllapot.DC)
    if ($minAllapot.AC -ge 50 -or $minAllapot.DC -ge 50) {
        Add-Figyelmeztetes 'A minimális processzorállapot magasra van állítva – a CPU alapjáraton sem lassít vissza (alapérték: 5%).'
    }
}
if ($maxAllapot) {
    Write-Log ("  Max. processzorállapot: hálózat {0}% / akku {1}%" -f $maxAllapot.AC, $maxAllapot.DC)
}

# Windows 10/11 energiamód (Beállítások > Rendszer > Energia) – a sémára rátett "overlay"
$overlay = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes'
$ismertModok = @{
    '961cc777-2547-4f9d-8174-7d86181b8a7a' = 'Legjobb energiahatékonyság'
    '00000000-0000-0000-0000-000000000000' = 'Kiegyensúlyozott'
    '3af9b8d9-7c97-431d-ad78-34a8bfea439f' = 'Jobb teljesítmény'
    'ded574b5-45a0-4f42-8737-46345c09c238' = 'Legjobb teljesítmény'
}
if ($overlay -and ($overlay.ActiveOverlayAcPowerScheme -or $overlay.ActiveOverlayDcPowerScheme)) {
    $acMod = "$($overlay.ActiveOverlayAcPowerScheme)".ToLower()
    $dcMod = "$($overlay.ActiveOverlayDcPowerScheme)".ToLower()
    $acNev = if ($ismertModok.ContainsKey($acMod)) { $ismertModok[$acMod] } else { 'ismeretlen' }
    $dcNev = if ($ismertModok.ContainsKey($dcMod)) { $ismertModok[$dcMod] } else { 'ismeretlen' }
    Write-Log ("  Windows energiamód: hálózat: {0} / akku: {1}" -f $acNev, $dcNev)
    if ($acMod -eq 'ded574b5-45a0-4f42-8737-46345c09c238' -or $dcMod -eq 'ded574b5-45a0-4f42-8737-46345c09c238') {
        Add-Figyelmeztetes "A Windows energiamód 'Legjobb teljesítmény' – ez is több hőt termel."
    }
}

# =====================================================================
#  7. AKKUMULÁTOR
# =====================================================================
Write-Szakasz '7. AKKUMULÁTOR'
$akku = Get-CimInstance Win32_Battery | Select-Object -First 1
if (-not $akku) {
    Write-Log '  Nincs akkumulátor (asztali gép?).'
} else {
    $allapotok = @{
        1 = 'Akkumulátorról megy'; 2 = 'Hálózati tápról (töltő bedugva)'; 3 = 'Teljesen feltöltve'
        4 = 'Alacsony'; 5 = 'Kritikus'; 6 = 'Töltődik'; 7 = 'Töltődik (magas)'; 8 = 'Töltődik (alacsony)'
        9 = 'Töltődik (kritikus)'; 10 = 'Ismeretlen'; 11 = 'Részben töltött'
    }
    Write-Log ("  Állapot:    {0}" -f $allapotok[[int]$akku.BatteryStatus])
    Write-Log ("  Töltöttség: {0}%" -f $akku.EstimatedChargeRemaining)

    try {
        $teljes  = (Get-CimInstance -Namespace 'root/wmi' -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity
        $gyari   = (Get-CimInstance -Namespace 'root/wmi' -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity
        if ($teljes -and $gyari) {
            $egeszseg = [math]::Round($teljes / $gyari * 100)
            Write-Log ("  Kapacitás:  {0} / {1} mWh – az eredeti {2}%-a" -f $teljes, $gyari, $egeszseg)
            if ($egeszseg -lt 60) {
                Add-Figyelmeztetes ("Az akkumulátor erősen kopott ({0}%). Nézd meg, nem duzzadt-e (felpúposodó touchpad, nyíló ház)!" -f $egeszseg)
            }
        }
    } catch {
        Write-Log '  Kapacitás: nem olvasható (rendszergazdaként futtatva látszik).' 'DarkGray'
    }

    $akkuRiport = Join-Path $LogDir "${gepNev}_${stamp}_battery-report.html"
    powercfg /batteryreport /output "$akkuRiport" 2>$null | Out-Null
    if (Test-Path $akkuRiport) { Write-Log "  Részletes akku-riport: $akkuRiport" }
}

# =====================================================================
#  8. AUTOMATIKUSAN INDULÓ PROGRAMOK
# =====================================================================
Write-Szakasz '8. AUTOMATIKUSAN INDULÓ PROGRAMOK'
$inditas = @(Get-CimInstance Win32_StartupCommand | Select-Object @{ n = 'Program'; e = { $_.Name } },
    @{ n = 'Hely'; e = { $_.Location } }, @{ n = 'Felhasználó'; e = { $_.User } })
Write-Log ("  Összesen: {0} db" -f $inditas.Count)
if ($inditas.Count -gt 0) { Write-Tabla $inditas }
if ($inditas.Count -ge 15) {
    Add-Figyelmeztetes ("Sok automatikusan induló program ({0} db) – lassítja az indulást és a háttérben is terhel." -f $inditas.Count)
}

# =====================================================================
#  9. ESEMÉNYNAPLÓ
# =====================================================================
Write-Szakasz '9. ESEMÉNYNAPLÓ (hiba-előzmények)'

$fojtas = Get-Esemenyek @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-Processor-Power'; Id = 37; StartTime = (Get-Date).AddDays(-7) }
Write-Log ("  CPU-fojtás a firmware által (ID 37), utolsó 7 nap:   {0} db" -f $fojtas.Count)
if ($fojtas.Count -gt 0) {
    Write-Log ("     legutóbb: {0:yyyy-MM-dd HH:mm}" -f $fojtas[0].TimeCreated) 'DarkGray'
    Add-Figyelmeztetes ("A firmware {0} alkalommal visszafogta a CPU-t az elmúlt héten – tipikusan túlmelegedés vagy gyenge töltő miatt." -f $fojtas.Count)
}

$leallas = Get-Esemenyek @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-Power'; Id = 41; StartTime = (Get-Date).AddDays(-30) }
Write-Log ("  Váratlan leállás (Kernel-Power 41), utolsó 30 nap:   {0} db" -f $leallas.Count)
if ($leallas.Count -gt 0) {
    Write-Log ("     legutóbb: {0:yyyy-MM-dd HH:mm}" -f $leallas[0].TimeCreated) 'DarkGray'
    Add-Figyelmeztetes ("{0} váratlan leállás az elmúlt 30 napban – túlmelegedéses lekapcsolás is okozhatja." -f $leallas.Count)
}

$kekhalal = Get-Esemenyek @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-WER-SystemErrorReporting'; Id = 1001; StartTime = (Get-Date).AddDays(-30) }
Write-Log ("  Kékhalál (BugCheck 1001), utolsó 30 nap:             {0} db" -f $kekhalal.Count)
if ($kekhalal.Count -gt 0) {
    Add-Figyelmeztetes ("{0} kékhalál az elmúlt 30 napban – driver- vagy hardverhiba gyanú." -f $kekhalal.Count) -Kritikus
}

$lemezHiba = Get-Esemenyek @{ LogName = 'System'; ProviderName = 'disk'; Id = 7, 51, 153; StartTime = (Get-Date).AddDays(-30) }
Write-Log ("  Lemezhibák (disk 7/51/153), utolsó 30 nap:           {0} db" -f $lemezHiba.Count)
if ($lemezHiba.Count -gt 0) {
    Add-Figyelmeztetes ("{0} lemezhiba-bejegyzés az elmúlt 30 napban – a lemez haldoklik, adatmentés javasolt!" -f $lemezHiba.Count) -Kritikus
}

# =====================================================================
#  10. MEGFIGYELÉS (opcionális)
# =====================================================================
if ($MonitorPerc -gt 0) {
    Write-Szakasz ("10. MEGFIGYELÉS – {0} perc, {1} mp-enként" -f $MonitorPerc, $IntervalMp)
    $csv = Join-Path $LogDir "${gepNev}_${stamp}_megfigyeles.csv"
    $vege = (Get-Date).AddMinutes($MonitorPerc)
    $csucsHo = $null; $csucsCpu = 0

    while ((Get-Date) -lt $vege) {
        $mintaMon = @(Get-FolyamatMinta -Mp 3)
        $hoMon    = @(Get-Homersekletek)
        $maxHoMon = if ($hoMon) { ($hoMon | Measure-Object Celsius -Maximum).Maximum } else { $null }
        $terhMon  = [math]::Round((Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average)
        $topMon   = $mintaMon | Sort-Object 'CPU %' -Descending | Select-Object -First 1

        if ($null -ne $maxHoMon -and ($null -eq $csucsHo -or $maxHoMon -gt $csucsHo)) { $csucsHo = $maxHoMon }
        if ($terhMon -gt $csucsCpu) { $csucsCpu = $terhMon }

        [pscustomobject]@{
            'Idő'            = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            'Max hő (°C)'    = $maxHoMon
            'CPU terhelés %' = $terhMon
            'Top folyamat'   = $topMon.Folyamat
            'Top CPU %'      = $topMon.'CPU %'
        } | Export-Csv -Path $csv -Append -NoTypeInformation -Delimiter ';' -Encoding UTF8

        $hoSzoveg = if ($null -ne $maxHoMon) { "$maxHoMon °C" } else { 'n/a' }
        Write-Log ("  {0}   hő: {1,-9} CPU: {2,3}%   top: {3} ({4}%)" -f (Get-Date -Format 'HH:mm:ss'), $hoSzoveg, $terhMon, $topMon.Folyamat, $topMon.'CPU %')

        $hatraVan = ($vege - (Get-Date)).TotalSeconds
        if ($hatraVan -le 0) { break }
        Start-Sleep -Seconds ([math]::Min([math]::Max(0, $IntervalMp - 3), $hatraVan))
    }
    Write-Log ''
    Write-Log ("  Csúcsértékek: hő {0} °C, CPU {1}%" -f $(if ($null -ne $csucsHo) { $csucsHo } else { 'n/a' }), $csucsCpu)
    Write-Log "  CSV (Excelben megnyitható): $csv"
    if ($null -ne $csucsHo -and $csucsHo -ge 90) {
        Add-Figyelmeztetes ("A megfigyelés alatt {0} °C-ig ment fel a hő." -f $csucsHo) -Kritikus
    }
}

# =====================================================================
#  ÖSSZEGZÉS
# =====================================================================
Write-Szakasz 'ÖSSZEGZÉS'
if ($Figyelmeztetesek.Count -eq 0) {
    Write-Log '  Nem találtam szoftveres okot. Ha a gép mégis forró, valószínűleg hardveres:' 'Green'
    Write-Log '  eltömődött szellőző/ventilátor, kiszáradt hővezető paszta, vagy az akkumulátor.' 'Green'
} else {
    Write-Log ("  {0} megállapítás:" -f $Figyelmeztetesek.Count) 'White'
    foreach ($f in $Figyelmeztetesek) {
        $szin = if ($f.StartsWith('[KRITIKUS]')) { 'Red' } else { 'Yellow' }
        Write-Log "  $f" $szin
    }
}

Write-Log ''
Write-Log '  Fizikai ellenőrzés (a script ezt nem látja):' 'White'
Write-Log '   - Szellőzőnyílások szabadok? (ágyon, ölben, puha felületen használja?)'
Write-Log '   - Pörög a ventilátor? Zúg, kattog, vagy épp néma, miközben a gép forró?'
Write-Log '   - Duzzadt akku jelei: felpúposodó touchpad/billentyűzet, nyíló ház -> AZONNAL ne használja!'
Write-Log '   - Gyári töltő van rajta? A gyenge töltő is okoz fojtást.'
Write-Log '   - Gyártói hardverteszt: HP – F2 (PC Hardware Diagnostics), Dell – F12 (ePSA), Lenovo – Vantage / Diagnostics.'

Write-Log ''
Write-Log "Log mentve: $LogFile" 'Green'
