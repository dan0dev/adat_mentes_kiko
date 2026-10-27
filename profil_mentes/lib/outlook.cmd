@call %*
@exit /b

rem ==========================================================
rem  Outlook-lista: csatolt PST-k es kezzel ellenorizendo tetelek
rem  Csak a registrybol olvas, az Outlookhoz nem nyul.
rem  A munka: ps\outlook_lista.ps1
rem  Hivas: %OUTLOOK% :CIMKE
rem ==========================================================

:LISTA_KESZIT
rem Az elokeszitesben fut: hol vannak a csatolt PST-k. Nem figyelmeztet, nem kerdez -
rem a PST barhol lehet, csak a helye szamit.
rem Kimenet: OL_STOP (mindig 0), OL_PST, OL_OUT
set "OL_STOP=0"
set "OL_OUT=%TEMP%\outlook_lista_%RANDOM%.txt"
set "OL_PST="
echo.
echo   !C_FEHER!Outlook-lista!C_0! – csatolt PST-fájlok keresése...
set "PS_FAJL=%PSDIR%\outlook_lista.ps1"
for /f "tokens=1,2 delims=|" %%a in ('%PS_FUTTAT% 2^>nul') do (
    if "%%a"=="SUM" set "OL_PST=%%b"
    if "%%a"=="PST" echo     !C_SZURKE!%%b!C_0!
)
if not defined OL_PST (
    echo   !C_SARGA!A PST-lista nem készült el – a PowerShell nem elérhető.!C_0!
    goto :eof
)
echo   !C_ZOLD!Kész:!C_0! %OL_PST% csatolt PST
goto :eof

:LISTA_MENT
rem Mentes lepes: az elokeszitesben keszult lista a celmappaba kerul
if not defined OL_PST (
    %UI% :JELOL HIBA "a lista nem készült el" "A PowerShell nem elérhető."
    goto :eof
)
if not exist "%OL_OUT%" (
    %UI% :JELOL HIBA "a lista nem készült el"
    goto :eof
)
if "%TESZTMOD%"=="1" (
    del /q "%OL_OUT%" >nul 2>&1
    %UI% :JELOL OK "%OL_PST% csatolt PST megtalálva"
    goto :eof
)
copy /Y "%OL_OUT%" "%CEL%\outlook_lista.txt" >nul 2>&1
del /q "%OL_OUT%" >nul 2>&1
if not exist "%CEL%\outlook_lista.txt" (
    %UI% :JELOL HIBA "nem másolható a mentésbe"
    goto :eof
)
%UI% :JELOL OK "%OL_PST% csatolt PST – outlook_lista.txt"
goto :eof
