# ==========================================================
#  Rendszergazdai ablak - lib\eszkozok.cmd :EMELES futtatja
#  A segedletet ujrainditja rendszergazdakent, egyenesen a rendszergazdai
#  eszkozokkel. A Windows itt keri egyszer a rendszergazdai jelszot.
#  Bemenet:  ES_INDITO - a kulso indito (vagy a segedlet.bat) teljes utja
#  Kimenet:  OK, vagy NEM|<ok>
# ==========================================================
$ErrorActionPreference = 'Stop'
$arg = '/c ""' + $env:ES_INDITO + '" ESZKOZOK"'
# Csatolt halozati meghajtot a rendszergazdai ablak nem lat: az ablak felvillanna es bezarulna
$halozati = $false
try { $gy = [IO.Path]::GetPathRoot($env:ES_INDITO); $halozati = ($gy -like '\\*') -or ((New-Object IO.DriveInfo $gy).DriveType -eq 'Network') } catch { }
if ($halozati) { 'NEM|Hálózati meghajtóról nem megy – másold a segédletet helyi lemezre vagy pendrive-ra.'; exit 0 }
try {
    Start-Process -FilePath (Join-Path $env:SystemRoot 'System32\cmd.exe') -ArgumentList $arg -Verb RunAs
    'OK'
} catch {
    # 1223: a jelszokero ablakot bezartak vagy a Nem gombot nyomtak
    if ($_.Exception.InnerException -and $_.Exception.InnerException.NativeErrorCode -eq 1223 -or $_.Exception.Message -match '1223|megszak|cancel') {
        'NEM|A jelszókérő ablakot bezártad – a rendszergazdai ablak nem nyílt meg.'
    } else {
        'NEM|A rendszergazdai ablak nem nyílt meg: ' + ($_.Exception.Message -replace '[|!%]', '')
    }
}
