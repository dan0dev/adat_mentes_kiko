@echo off
rem ==========================================================
rem  Robocopy folyamatjelzovel - csak a lib\masolas.cmd hivja, csovon at:
rem    call robo_prog.cmd | powershell ... ps\folyamat.ps1
rem  A cso jobb oldala a kimenetet alakitja (UTF-8, behuzas), ezert a
rem  robocopy kilepesi kodja fajlba kerul: R_RCF.
rem  Bemenet: R_SRC, R_DST, R_OPT, R_LOGT, R_RCF
rem ==========================================================
robocopy "%R_SRC%" "%R_DST%" %R_OPT% /FFT /R:1 /W:1 /NJH /NJS /NDL /NC /NS /TEE /UNICODE /UNILOG:"%R_LOGT%"
>"%R_RCF%" echo %errorlevel%
