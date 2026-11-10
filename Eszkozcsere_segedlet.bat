@echo off
rem ==========================================================
rem  Eszkozcsere segedlet - indito
rem  Ezt a fajlt kell elinditani. O maga sosem valtozik: a program a mellette
rem  levo profil_mentes mappaban van, es az frissul verziorol verziora.
rem ==========================================================
if exist "%~dp0profil_mentes\segedlet.bat" (
    call "%~dp0profil_mentes\segedlet.bat" %*
    exit /b
)
>nul chcp 65001 <nul
echo.
echo   Nem találom a profil_mentes mappát ennek a fájlnak a mappájában:
echo   %~dp0
echo   Az Eszkozcsere_segedlet.bat és a profil_mentes mappa legyen egymás mellett.
echo.
echo   Kilépéshez nyomj meg egy billentyűt…
pause >nul
exit /b 1
