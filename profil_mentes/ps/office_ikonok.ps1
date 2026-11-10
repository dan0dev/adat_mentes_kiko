# ==========================================================
#  Office-parancsikonok az asztalon - lib\ikonok.cmd futtatja
#  IK_MOD:
#    MENT     a regi gep asztalan levo Office-ikonok listaja (IK_FAJL) - visszaallitaskor
#             ezek is kikerulnek, nem csak az alapok
#    VIZSGAL  hany parancsikont kellene kirakni vagy javitani - a kimenet egy szam
#    JAVIT    kirakja a hianyzokat, torli/lecsereli a hibasakat (pl. Office 2016 -> 365:
#             a regi utvonal az uj gepen mar nincs meg). Kimenet: OK|uzenet|reszlet vagy HIBA|...
#  Bemenet:  IK_APPOK  nev|exe|alap|mas nevek (alap 1 = mindig kell, ha telepitve van), pontosvesszovel
#            IK_FAJL   a mentes asztal_office.txt-je
#            DESK      a felhasznalo asztala; IK_KOZOS a kozos asztal (alapbol PUBLIC\Desktop)
#  A program helye: a Windows App Paths bejegyzese - ez Office 2016-nal, 365-tel, 32 es 64
#  biten is a valodi helyet adja; tartalek: a szokasos Office-mappak.
# ==========================================================
$ErrorActionPreference = 'SilentlyContinue'
$sh = New-Object -ComObject WScript.Shell
$asztal = $env:DESK
$kozos = $env:IK_KOZOS; if (-not $kozos) { $kozos = Join-Path $env:PUBLIC 'Desktop' }
$appok = foreach ($x in ($env:IK_APPOK -split ';' | Where-Object { $_ })) {
    $r = $x -split '\|'
    $nevek = @($r[0]) + @(($r[3] -split ',') | Where-Object { $_ })
    [pscustomobject]@{ Nev = $r[0]; Exe = $r[1]; Alap = ($r[2] -eq '1'); Minta = '^(Microsoft (Office )?)?(' + (($nevek | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')( 20\d\d)?$' }
}

function Telepitve($exe) {
    # Kimenet: @{ Cel; Arg; Ikon } vagy $null
    if ($exe -eq 'TEAMS') {
        $p = Get-AppxPackage -Name 'MSTeams' | Select-Object -First 1
        if ($p) { return @{ Cel = (Join-Path $env:WINDIR 'explorer.exe'); Arg = 'shell:AppsFolder\MSTeams_8wekyb3d8bbwe!MSTeams'; Ikon = (Join-Path $p.InstallLocation 'ms-teams.exe') + ',0' } }
        $u = Join-Path $env:LOCALAPPDATA 'Microsoft\Teams\Update.exe'
        if (Test-Path -LiteralPath $u) { return @{ Cel = $u; Arg = '--processStart "Teams.exe"'; Ikon = (Join-Path $env:LOCALAPPDATA 'Microsoft\Teams\Current\Teams.exe') + ',0' } }
        return $null
    }
    foreach ($k in 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths') {
        $ut = (Get-ItemProperty -LiteralPath (Join-Path $k $exe)).'(default)'
        if ($ut) { $ut = $ut.Trim('"'); if (Test-Path -LiteralPath $ut) { return @{ Cel = $ut; Arg = ''; Ikon = "$ut,0" } } }
    }
    foreach ($pf in $env:ProgramFiles, ${env:ProgramFiles(x86)}) {
        foreach ($m in 'Microsoft Office\root\Office16', 'Microsoft Office\Office16', 'Microsoft Office\root\Office15', 'Microsoft Office\Office15') {
            $ut = Join-Path (Join-Path $pf $m) $exe
            if ($pf -and (Test-Path -LiteralPath $ut)) { return @{ Cel = $ut; Arg = ''; Ikon = "$ut,0" } }
        }
    }
    return $null
}
# Melyik apphoz tartozik egy parancsikon: a cel fajlneve, Teamsnel a cel/argumentum, kulonben a nev
function Melyik($lnk) {
    $c = $sh.CreateShortcut($lnk.FullName)
    $celnev = [IO.Path]::GetFileName($c.TargetPath)
    foreach ($a in $appok) {
        if ($a.Exe -eq 'TEAMS') {
            if ($c.Arguments -match 'MSTeams|Teams\.exe' -or $celnev -match '^(ms-)?teams\.exe$' -or $lnk.BaseName -match $a.Minta) { return @{ App = $a; Lnk = $c } }
        } elseif ($celnev -ieq $a.Exe -or $lnk.BaseName -match $a.Minta) { return @{ App = $a; Lnk = $c } }
    }
    return $null
}
function Mukodik($c) { return [bool]($c.TargetPath -and (Test-Path -LiteralPath $c.TargetPath)) }
function AsztaliIkonok {
    foreach ($d in $asztal, $kozos) {
        if ($d -and (Test-Path -LiteralPath $d)) {
            foreach ($f in Get-ChildItem -LiteralPath $d -Filter '*.lnk' -File) { $m = Melyik $f; if ($m) { [pscustomobject]@{ Fajl = $f.FullName; App = $m.App; Mukodik = (Mukodik $m.Lnk) } } }
        }
    }
}

# ---------- Mentes: a regi gep asztali Office-ikonjai ----------
if ($env:IK_MOD -eq 'MENT') {
    $nevek = @(AsztaliIkonok | ForEach-Object { $_.App } | Sort-Object Nev -Unique)
    [IO.File]::WriteAllLines($env:IK_FAJL, [string[]]@($nevek | ForEach-Object { $_.Exe }), (New-Object Text.UTF8Encoding $false))
    ($nevek | ForEach-Object { $_.Nev }) -join ', '
    exit 0
}

# ---------- Terv: mi kell, mi van, mi rossz ----------
$regi = @(); if ($env:IK_FAJL -and (Test-Path -LiteralPath $env:IK_FAJL)) { $regi = @(Get-Content -LiteralPath $env:IK_FAJL | Where-Object { $_ }) }
$ikonok = @(AsztaliIkonok)
$torol = @($ikonok | Where-Object { -not $_.Mukodik })
$kirak = @()
foreach ($a in $appok) {
    if (-not ($a.Alap -or $regi -contains $a.Exe)) { continue }
    $t = Telepitve $a.Exe
    if (-not $t) { continue }
    if (@($ikonok | Where-Object { $_.App.Exe -eq $a.Exe -and $_.Mukodik }).Count) { continue }
    $kirak += [pscustomobject]@{ App = $a; T = $t }
}
if ($env:IK_MOD -eq 'VIZSGAL') { $torol.Count + $kirak.Count; exit 0 }

# ---------- Javitas ----------
$kesz = @(); $hiba = @()
if ($asztal -and -not (Test-Path -LiteralPath $asztal)) { New-Item -ItemType Directory -Force -Path $asztal | Out-Null }
foreach ($x in $torol) {
    Remove-Item -LiteralPath $x.Fajl -Force
    if (Test-Path -LiteralPath $x.Fajl) { $hiba += $x.App.Nev } else { $kesz += $x }
}
foreach ($x in $kirak) {
    try {
        $c = $sh.CreateShortcut((Join-Path $asztal ($x.App.Nev + '.lnk')))
        $c.TargetPath = $x.T.Cel
        if ($x.T.Arg) { $c.Arguments = $x.T.Arg }
        $c.IconLocation = $x.T.Ikon
        $c.WorkingDirectory = Split-Path -Parent $x.T.Cel
        $c.Save()
        $kesz += $x
    } catch { $hiba += $x.App.Nev }
}
if ($hiba.Count) {
    'HIBA|nem sikerült automatikusan|Tedd ki kézzel: ' + (($hiba | Sort-Object -Unique) -join ', ')
} else {
    # Reszlet: Kirakva: Word, Excel · Régi törölve: Skype - legfeljebb 62 karakter
    $ki = @($kesz | Where-Object { $_.T } | ForEach-Object { $_.App.Nev })
    $tor = @($kesz | Where-Object { -not $_.T } | ForEach-Object { $_.App.Nev } | Sort-Object -Unique)
    $r = @(); if ($ki.Count) { $r += 'Kirakva: ' + ($ki -join ', ') }; if ($tor.Count) { $r += 'Régi törölve: ' + ($tor -join ', ') }
    $r = $r -join ' · '; if ($r.Length -gt 62) { $r = $r.Substring(0, 61) + '…' }
    'OK|' + ($kirak.Count + $torol.Count) + ' ikon beállítva|' + $r
}
