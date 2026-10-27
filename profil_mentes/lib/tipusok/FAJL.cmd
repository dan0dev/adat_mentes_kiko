@call %*
@exit /b

rem ==========================================================
rem  Tetel tipus: FAJL - egyetlen fajl egy mappabol
rem  T_P1 = fajlnev
rem  T_P2 = mi tortenjen sikeres visszaallitas utan, hogy a Windows betoltse:
rem         az :UTANA_<T_P2> cimke fut, pl. EXPLORER, STARTMENU. Ures: semmi.
rem ==========================================================

:MENT
call :FAJL "%T_FORRAS%" "%CEL%\%T_MAPPA%" "%T_P1%"
goto :eof

:VISSZA
call :FAJL "%FORRAS%\%T_MAPPA%" "%T_FORRAS%" "%T_P1%"
if not defined T_P2 goto :eof
if not "!E_%LEPES%!"=="OK" goto :eof
call :UTANA_%T_P2%
goto :eof

:UTANA_EXPLORER
%UI% :VALASZT IN "Újraindítsam a Fájlkezelőt a Gyorselérés betöltéséhez?"
if errorlevel 2 goto :eof
taskkill /F /IM explorer.exe >nul 2>&1
start "" explorer.exe
%UI% :RESZLET "Fájlkezelő újraindítva."
goto :eof

:UTANA_STARTMENU
rem A Start menu a start2.bin-t csak indulaskor olvassa be. Leallitva a Windows magatol ujrainditja.
%UI% :VALASZT IN "Újraindítsam a Start menüt a rögzítések betöltéséhez?"
if errorlevel 2 goto :eof
taskkill /F /IM StartMenuExperienceHost.exe >nul 2>&1
%UI% :RESZLET "Start menü újraindítva."
%UI% :RESZLET "Ami ezen a gépen nincs telepítve, annak a rögzítése kimarad."
goto :eof

:FAJL
rem %1 = forras mappa, %2 = cel mappa, %3 = fajlnev
if not exist "%~1\%~3" (
    >>"%LOG%" echo        nincs ilyen fájl: %~1\%~3
    %UI% :JELOL KIHAGYVA "ezen a gépen nincs ilyen fájl"
    goto :eof
)
set "R_SRC=%~1"
set "R_DST=%~2"
set "R_OPT=%~3"
set "R_PROG=0"
%MASOLAS% :ROBO
%UI% :JELOL %R_ALLAPOT% "%R_UZENET%" "%R_RESZLET%"
goto :eof
