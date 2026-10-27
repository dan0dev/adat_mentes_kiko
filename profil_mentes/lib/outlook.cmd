@call %*
@exit /b

rem ==========================================================
rem  Outlook lista: csatolt PST-k es kezzel ellenorizendo tetelek
rem  Csak a registrybol olvas, az Outlookhoz nem nyul.
rem  A munka: ps\outlook_lista.ps1
rem  Hivas: %OUTLOOK% :CIMKE
rem ==========================================================

:LISTA_KESZIT
rem Az elokeszitesben fut.  Kimenet: OL_STOP, OL_PST, OL_KINT, OLK_n, OL_OUT
set "OL_STOP=0"
set "OL_OUT=%TEMP%\outlook_lista_%RANDOM%.txt"
set "OL_PST="
set "OL_KINT=0"
echo.
echo    !C_FEHER!Outlook lista!C_0! - csatolt PST adatfajlok keresese...
set "PS_FAJL=%PSDIR%\outlook_lista.ps1"
for /f "tokens=1,2 delims=|" %%a in ('%PS_FUTTAT% 2^>nul') do (
    if "%%a"=="SUM" set "OL_PST=%%b"
    if "%%a"=="KINT" (
        set /a OL_KINT+=1
        set "OLK_!OL_KINT!=%%b"
        echo    !C_SARGA!FIGYELEM: ez a PST nem a PST mappaban van, igy nem kerul mentesre:!C_0!
        echo      %%b
    )
)
if not defined OL_PST (
    echo    !C_SARGA![i] A PST lista nem keszult el - a PowerShell nem elerheto.!C_0!
    goto :eof
)
echo    !C_ZOLD!Kesz:!C_0! %OL_PST% csatolt PST
if "%OL_KINT%"=="0" goto :eof
if "%TESZTMOD%"=="1" goto :eof
echo    !C_SARGA!A fenti PST-ket az Outlook bezarasa utan masold at kezzel a %SRC_PST% mappaba,!C_0!
echo    !C_SARGA!es inditsd ujra a mentest. Az uj gepen onnan kell majd csatolni oket.!C_0!
%UI% :VALASZT FM "   F = folytatas igy, M = megszakitas"
if errorlevel 2 set "OL_STOP=1"
goto :eof

:LISTA_MENT
rem Mentes lepes: az elokeszitesben keszult lista a celmappaba kerul
if not defined OL_PST (
    %UI% :JELOL HIBA "nem keszult el - a PowerShell nem elerheto"
    goto :eof
)
if not exist "%OL_OUT%" (
    %UI% :JELOL HIBA "nem keszult el"
    goto :eof
)
if "%TESZTMOD%"=="1" (
    del /q "%OL_OUT%" >nul 2>&1
    if not "%OL_KINT%"=="0" (
        %UI% :JELOL HIBA "%OL_KINT% PST a PST mappan kivul van - eles mentesnel nem kerulne mentesre"
    ) else (
        %UI% :JELOL OK "%OL_PST% csatolt PST megtalalva"
    )
    goto :eof
)
copy /Y "%OL_OUT%" "%CEL%\outlook_lista.txt" >nul 2>&1
del /q "%OL_OUT%" >nul 2>&1
if not exist "%CEL%\outlook_lista.txt" (
    %UI% :JELOL HIBA "nem masolhato a celmappaba"
    goto :eof
)
if not "%OL_KINT%"=="0" (
    %UI% :JELOL HIBA "%OL_PST% PST, ebbol %OL_KINT% a PST mappan kivul - nincs mentve"
) else (
    %UI% :JELOL OK "%OL_PST% csatolt PST - outlook_lista.txt"
)
goto :eof
