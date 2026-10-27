@echo off
rem Wrapper a futtat.ps1-hez: kodlap beallitasa, a segedlet futtatasa, a kodlap kiirasa a vegen.
rem %1 = kodlap (0 = nem valt), %2 = Eszkozcsere_segedlet.bat utvonala
if not "%~1"=="0" chcp %~1 >nul <nul
call "%~2"
set "RC=%errorlevel%"
echo.
echo PM_VEGE kilepesi kod: %RC%
chcp <nul
exit /b %RC%
