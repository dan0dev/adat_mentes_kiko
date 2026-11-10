# ==========================================================
#  A bejelentkezett felhasznalo neve - lib\ellenorzes.cmd :FELHASZNALO futtatja
#  Az ebben a munkamenetben futo Fajlkezelo (explorer.exe) tulajdonosa: o az, aki
#  a gep elott ul. Ha a segedlet mas fiokkal fut rendszergazdakent, a ketto elter.
#  Kimenet: a felhasznalonev, vagy semmi, ha nem allapithato meg
# ==========================================================
$ErrorActionPreference = 'SilentlyContinue'
$munkamenet = (Get-Process -Id $PID).SessionId
$e = Get-CimInstance Win32_Process -Filter "Name='explorer.exe'" | Where-Object SessionId -eq $munkamenet | Select-Object -First 1
if ($e) {
    $t = Invoke-CimMethod -InputObject $e -MethodName GetOwner
    if ($t -and $t.User) { $t.User }
}
