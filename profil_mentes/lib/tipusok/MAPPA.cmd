@call %*
@exit /b

rem ==========================================================
rem  Tetel tipus: MAPPA - egy teljes mappa almappakkal
rem  T_P1 = jelzok, egyutt is, pl. PJ:
rem         P = folyamatjelzo, nagy mappakhoz
rem         J = puffer nelkuli masolas - robocopy /J, nagy fajlokhoz, pl. PST
rem ==========================================================

:MENT
call :MAPPA "%T_FORRAS%" "%CEL%\%T_MAPPA%" %T_P1%
goto :eof

:VISSZA
call :MAPPA "%FORRAS%\%T_MAPPA%" "%T_FORRAS%" %T_P1%
goto :eof

:MAPPA
rem %1 = forras mappa, %2 = cel mappa, %3 = jelzok: P, J vagy PJ
if not exist "%~1\" (
    >>"%LOG%" echo        nincs ilyen mappa: %~1
    %UI% :JELOL KIHAGYVA "ezen a gépen nincs ilyen mappa"
    goto :eof
)
set "R_SRC=%~1"
set "R_DST=%~2"
set "R_OPT=/E /DCOPY:T /XJ"
set "R_PROG=0"
set "_jel=#%~3"
if /I not "!_jel:P=!"=="!_jel!" set "R_PROG=1"
if /I not "!_jel:J=!"=="!_jel!" set "R_OPT=!R_OPT! /J"
%MASOLAS% :ROBO
if not "%R_ALLAPOT%"=="OK" (
    %UI% :JELOL HIBA "%R_UZENET%" "%R_RESZLET%"
    goto :eof
)
set "FDB=0"
set "_hol=%R_DST%"
if "%TESZTMOD%"=="1" set "_hol=%R_SRC%"
for /f %%c in ('dir /a-d /b /s "%_hol%" 2^>nul ^| find /c /v ""') do set "FDB=%%c"
if "%TESZTMOD%"=="1" (
    %UI% :JELOL OK "%FDB% fájl, elérhető – menthető"
) else (
    %UI% :JELOL OK "%FDB% fájl, ellenőrizve"
)
goto :eof
