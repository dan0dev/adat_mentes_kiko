@call %*
@exit /b

rem ==========================================================
rem  Tetel tipus: MINTA - egy mappa adott mintaju fajljai, almappak nelkul
rem  pl. az Office mappabol csak a *.acl (automatikus javitas) fajlok
rem  T_P1 = a minta, pl. *.acl
rem ==========================================================

:MENT
set "_nincs=ezen a gépen nincs ilyen fájl"
call :MINTA "%T_FORRAS%" "%CEL%\%T_MAPPA%"
goto :eof

:VISSZA
set "_nincs=nincs a mentésben"
call :MINTA "%FORRAS%\%T_MAPPA%" "%T_FORRAS%"
goto :eof

:MINTA
rem %1 = forras mappa, %2 = cel mappa
set "_mdb=0"
rem A for a mintat az aktualis mappaban bontana ki - a dir a megadott mappaban szamol
if exist "%~1\" for /f %%c in ('dir /b /a-d "%~1\%T_P1%" 2^>nul ^| find /c /v ""') do set "_mdb=%%c"
if %_mdb%==0 (
    >>"%LOG%" echo        nincs ilyen fájl: %~1\%T_P1%
    %UI% :JELOL KIHAGYVA "!_nincs!"
    goto :eof
)
set "R_SRC=%~1"
set "R_DST=%~2"
set "R_OPT=%T_P1%"
set "R_PROG=0"
%MASOLAS% :ROBO
if not "%R_ALLAPOT%"=="OK" (
    %UI% :JELOL HIBA "%R_UZENET%" "%R_RESZLET%"
    goto :eof
)
%UI% :JELOL OK "%_mdb% fájl, ellenőrizve"
goto :eof
