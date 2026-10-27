# ==========================================================
#  Telepitett programok listaja - lib\programlista.cmd futtatja
#  Bemenet:  APPS_FAJL - a kimeneti fajl
#  Soronkent: Nev  |  Verzio  |  Kiado
# ==========================================================
$ErrorActionPreference = 'Stop'
$k = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
     'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
     'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
$l = Get-ItemProperty -Path $k -ErrorAction SilentlyContinue |
     Where-Object { $_.DisplayName -and -not $_.SystemComponent } |
     Sort-Object DisplayName -Unique |
     ForEach-Object { '{0}  |  {1}  |  {2}' -f $_.DisplayName, $_.DisplayVersion, $_.Publisher }
$l | Out-File -LiteralPath $env:APPS_FAJL -Encoding UTF8
