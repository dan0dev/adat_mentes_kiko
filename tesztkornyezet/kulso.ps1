# ==========================================================
#  A hamis kulso meghajto mappaja - a futtat.ps1 es a mind.ps1 is ezt hasznalja
#  PM_TESZT_KULSO felulirja; kulonben az E: meghajton, ha van (nem a rendszerlemezen),
#  vegul a TEMP alatt. A futtat.ps1 ezt a mappat T:-kent (vagy a kovetkezo szabad
#  betukent) csatolja subst-tal, es a teszt utan is csatolva hagyja.
# ==========================================================
if ($env:PM_TESZT_KULSO) { return $env:PM_TESZT_KULSO }
if (Test-Path 'E:\') { return 'E:\Eszkozcsere_teszt\kulso' }
return (Join-Path $env:TEMP 'pm_teszt\kulso')
