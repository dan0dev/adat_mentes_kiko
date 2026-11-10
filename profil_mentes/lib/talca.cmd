@call %*
@exit /b

rem ==========================================================
rem  A talcara rogzitett ikonok listaja - talca.txt -, mellette kep a talcarol - talca.png
rem  Ujra rogziteni kezzel kell: Windows 11-en script nem tud megbizhatoan rogziteni.
rem  Hivas: %TALCA% :LISTA "kimeneti fajl"
rem ==========================================================

:LISTA
rem %1 = kimeneti fajl. Elsodlegesen PowerShell - ps\talca.ps1 -, ha tiltva van, csak a parancsikonok neve.
rem A kep ugyanabba a mappaba kerul, talca.png neven - ps\talca_kep.ps1
set "TALCA_FAJL=%~1"
set "TALCA_KEP=%~dp1talca.png"
set "TALCA_DB="
call :KEP
set "PS_FAJL=%PSDIR%\talca.ps1"
for /f %%c in ('%PS_FUTTAT% 2^>nul') do set "TALCA_DB=%%c"
if defined TALCA_DB if exist "%TALCA_FAJL%" goto :KESZ
%UI% :RESZLET "a PowerShell nem elérhető, csak az asztali programok kerülnek a listára"
set /a TALCA_DB=0
set "_tb=%APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
>"%TALCA_FAJL%" echo %USERNAME% · %COMPUTERNAME% · %DATUM_SZEP%
>>"%TALCA_FAJL%" echo.
for %%f in ("%_tb%\*.lnk") do (
    >>"%TALCA_FAJL%" echo – %%~nf
    set /a TALCA_DB+=1
)
>>"%TALCA_FAJL%" echo.
>>"%TALCA_FAJL%" echo Eszközcsere segédlet %VERZIO% · Készítette: %SZERZO%
:KESZ
if not "%TALCA_KEP_OK%"=="1" %UI% :RESZLET "Kép nem készült: !TALCA_KEP_OK!."
if "%TALCA_DB%"=="0" (
    %UI% :JELOL KIHAGYVA "nincs rögzített ikon a tálcán"
    goto :eof
)
if "%TALCA_KEP_OK%"=="1" (
    %UI% :JELOL OK "%TALCA_DB% ikon – talca.txt, talca.png"
) else (
    %UI% :JELOL OK "%TALCA_DB% ikon – talca.txt"
)
goto :eof

:KEP
rem Kep a fo kijelzo talcajarol. Kimenet: TALCA_KEP_OK = 1, vagy az ok, amiert nem keszult
set "TALCA_KEP_OK=a PowerShell nem elérhető"
if exist "%TALCA_KEP%" del /q "%TALCA_KEP%" >nul 2>&1
set "PS_FAJL=%PSDIR%\talca_kep.ps1"
for /f "tokens=1,* delims=|" %%a in ('%PS_FUTTAT% 2^>nul') do (
    if "%%a"=="OK" set "TALCA_KEP_OK=1"
    if "%%a"=="NEM" set "TALCA_KEP_OK=%%b"
)
if "%TALCA_KEP_OK%"=="1" if not exist "%TALCA_KEP%" set "TALCA_KEP_OK=a kép nem menthető"
goto :eof
