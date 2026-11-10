@call %*
@exit /b

rem ==========================================================
rem  Tetel tipus: MAPPA - egy teljes mappa almappakkal
rem  T_P1 = jelzok, egyutt is, pl. PJ:
rem         P = folyamatjelzo, nagy mappakhoz
rem         J = puffer nelkuli masolas - robocopy /J, nagy fajlokhoz
rem         A = atugorhato: masolas kozben a K billentyuvel kihagyhato (folyamatjelzovel megy)
rem ==========================================================

:MENT
set "_nincs=ezen a gépen nincs ilyen mappa"
call :MAPPA "%T_FORRAS%" "%CEL%\%T_MAPPA%" %T_P1%
goto :eof

:VISSZA
set "_nincs=nincs a mentésben"
call :MAPPA "%FORRAS%\%T_MAPPA%" "%T_FORRAS%" %T_P1%
goto :eof

:MAPPA
rem %1 = forras mappa, %2 = cel mappa, %3 = jelzok: P, J, A, egyutt is, pl. PJA
if not exist "%~1\" (
    >>"%LOG%" echo        nincs ilyen mappa: %~1
    %UI% :JELOL KIHAGYVA "!_nincs!"
    goto :eof
)
set "R_SRC=%~1"
set "R_DST=%~2"
set "R_OPT=/E /DCOPY:T /XJ"
set "R_PROG=0"
set "R_ATUGORHATO=0"
set "_jel=#%~3"
if /I not "!_jel:P=!"=="!_jel!" set "R_PROG=1"
if /I not "!_jel:J=!"=="!_jel!" set "R_OPT=!R_OPT! /J"
if /I not "!_jel:A=!"=="!_jel!" set "R_ATUGORHATO=1" & set "R_PROG=1"
if "%R_ATUGORHATO%"=="1" echo !UI_BEHUZAS!!C_SZURKE!K – átugrás, ha túl sokáig tart!C_0!
%MASOLAS% :ROBO
if "%R_ALLAPOT%"=="ATUGORVA" (
    set /a DB_ATUGORVA+=1
    %UI% :JELOL KIHAGYVA "%R_UZENET%" "%R_RESZLET%"
    goto :eof
)
if not "%R_ALLAPOT%"=="OK" (
    %UI% :JELOL HIBA "%R_UZENET%" "%R_RESZLET%"
    goto :eof
)
set "FDB=0"
for /f %%c in ('dir /a-d /b /s "%R_DST%" 2^>nul ^| find /c /v ""') do set "FDB=%%c"
%UI% :JELOL OK "%FDB% fájl, ellenőrizve"
goto :eof
